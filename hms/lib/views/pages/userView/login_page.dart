import 'dart:convert';
import 'package:hms/views/pages/dashboardView/dashboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/fireStore_service/companiesCollection_service.dart';
import 'package:hms/fireStore_service/userCollection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? companyId = null;
  String? companyName = null;
  final UsercollectionService _usercollectionService = UsercollectionService();
  final CompanycollectionService _companycollectionService =
      CompanycollectionService();
  List<String> companyFeatures = [];
  @override
  void initState() {
    super.initState();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Enter your email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter your email')),
                  );
                  return;
                }
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password reset email sent!')),
                  );
                } on FirebaseAuthException catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.message}')),
                  );
                }
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorMessage(BuildContext context, String message) async {
    await PopupMessage.show(
      context,
      title: 'Login Failed',
      message: message,
      icon: Icons.error_outline,
      iconColor: Colors.red,
      actionButtons: [
        PopupActionButton(
          label: 'OK',
          icon: Icons.check,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      autoDismiss: false, // so user manually closes after reading
    );
  }

  // Login logic
  void login(BuildContext context) async {
    if (!_validateFields(context)) return;

    final inputUsername = usernameController.text.trim();
    final inputPassword = passwordController.text.trim();

    try {
      // Try Firebase Authentication
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: inputUsername,
        password: inputPassword,
      );

      final user = authResult.user;

      if (user != null) {
        final userId = user.uid;
        final email = user.email;

        final db = FirebaseFirestore.instance;
        final userDoc = await db.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final userlevel = userData?['userlevel'] ?? 'user';
          final companyId = userData?['companyId'] ?? '1';
          final List<dynamic> rawFeatures = userData?['features'] ?? [];
          final List<String> userFeatures = rawFeatures
              .whereType<String>()
              .toList();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userFeatures', jsonEncode(userFeatures));

          // Fetch company info and features
          try {
            final companies = await _companycollectionService.getAllCompanies();

            final matchedCompany = companies.firstWhere(
              (company) => company['id'] == companyId,
              orElse: () {
                print("CompanyId not matched, using default.");
                return {
                  'companyname': 'Default Company',
                  'featuresEnabled': [],
                };
              },
            );

            companyName = matchedCompany['companyname'];

            // Subscription check
            if (matchedCompany.containsKey('renewalDate') &&
                matchedCompany['renewalDate'] != null) {
              final renewalDate = (matchedCompany['renewalDate'] as Timestamp)
                  .toDate();

              if (userlevel != 'DevelopAdmin' &&
                  DateTime.now().isAfter(renewalDate)) {
                _showErrorMessage(
                  context,
                  'Your subscription has expired. Please contact your administrator.',
                );
                return;
              }
            }

            // Extract featuresEnabled
            List<String> features = [];
            if (matchedCompany.containsKey('featuresEnabled') &&
                matchedCompany['featuresEnabled'] is List) {
              features = List<String>.from(matchedCompany['featuresEnabled']);
            }

            await prefs.setString('companyFeatures', jsonEncode(features));
            companyFeatures = features;
          } catch (e) {
            print("Error while fetching company data: $e");
            companyName = 'Default Company';
            await prefs.setString('companyFeatures', jsonEncode([]));
            companyFeatures = [];
          }

          // Save user info
          await prefs.setString('loggedInUsername', inputUsername);
          await prefs.setString('userlevel', userlevel);
          await prefs.setString('userId', userId);
          await prefs.setString('email', email ?? '');
          await prefs.setString('companyId', companyId);
          await prefs.setString(
            'companyName',
            companyName ?? 'Default Company',
          );
          //await FirestoreService().initializeDefaults();

          // Navigate to Dashboard
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          await _showErrorMessage(context, "Please enter Valid Credentials!");
        }
      } else {
        await _showErrorMessage(context, "Please enter Valid Credentials!");
      }
    } on FirebaseAuthException catch (e) {
      // Always log the full error for debugging
      print('FirebaseAuthException: ${e.code} - ${e.message}');

      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email format.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          // These all indicate bad login
          errorMessage =
              'Invalid credentials. Please check your email and password.';
          break;
        default:
          errorMessage = 'Authentication failed. Please try again.';
      }

      await _showErrorMessage(context, errorMessage);
    } catch (e) {
      print('Unexpected login error: $e');
      await _showErrorMessage(
        context,
        'An unexpected error occurred. Please try again later.',
      );
    }
  }

  // Validate the form fields
  bool _validateFields(BuildContext context) {
    if (usernameController.text.trim().isEmpty) {
      _showErrorMessage(context, 'Username is required');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _showErrorMessage(context, 'Password is required');
      return false;
    }
    return true;
  }

  // Show error message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 64, color: Colors.indigo),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: Icon(Icons.login, color: Colors.white),
                      label: Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _showForgotPasswordDialog(context),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildFooterLink(BuildContext context, String label, String route) {
  return TextButton(
    onPressed: () => Navigator.pushNamed(context, route),
    child: Text(
      label,
      style: TextStyle(
        color: Colors.indigo,
        fontSize: 12,
        decoration: TextDecoration.underline,
      ),
    ),
  );
}
