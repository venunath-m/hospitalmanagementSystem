import 'package:hms/constants/features_toggle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/fireStore_service/companiesCollection_service.dart';
import 'package:hms/fireStore_service/userCollection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRegistrationPage extends StatefulWidget {
  String? loggedInUserCompanyId;
  final String? loggedInUserCompanyName;

  UserRegistrationPage({
    super.key,
    this.loggedInUserCompanyId,
    required this.loggedInUserCompanyName,
  }) {
    //print("UserRegistrationPage widget created");
  }

  @override
  State<UserRegistrationPage> createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final TextStyle headerStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  Map<String, Map<String, bool>>? togglesState;
  List<Map<String, dynamic>> allUsers = [];
  int currentPage = 0;
  final int pageSize = 5;

  Future<void> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      allUsers = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'uid': doc.id})
          .toList();
    });
  }

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final userlevelController = TextEditingController();
  final emailController = TextEditingController();
  final companySearchController = TextEditingController();
  String initialUserLevel = '';

  final UsercollectionService _usercollectionService = UsercollectionService();
  final CompanycollectionService _companycollectionService =
      CompanycollectionService();
  String? selectedCompanyId;
  String? selectedCompanyName;
  List<Map<String, dynamic>> companyList = [];

  @override
  void initState() {
    super.initState();
    loadUserLevel();
    togglesState = {};
    FeatureToggles.categorized.forEach((category, features) {
      togglesState?[category] = Map<String, bool>.from(features);
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    userlevelController.dispose();
    emailController.dispose();
    companySearchController.dispose();
    super.dispose();
  }

  void loadUserForEditing(Map<String, dynamic> user) {
    usernameController.text = user['username'] ?? '';
    emailController.text = user['email'] ?? '';
    userlevelController.text = user['userlevel'] ?? '';
    selectedCompanyId = user['companyId'];

    // Reset togglesState all to false
    togglesState?.forEach((category, features) {
      features.updateAll((key, value) => false);
    });

    // Set togglesState true for user's features
    if (user['features'] != null && user['features'] is List) {
      for (final feature in user['features']) {
        togglesState?.forEach((category, features) {
          if (features.containsKey(feature)) {
            features[feature] = true;
          }
        });
      }
    }

    setState(() {});
  }

  void loadUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    initialUserLevel = prefs.getString('userlevel') ?? '';
    widget.loggedInUserCompanyId = prefs.getString('companyId') ?? '';

    if (initialUserLevel != "DevelopAdmin" &&
        userlevelController.text.isEmpty) {
      userlevelController.text = 'SuperAdmin';
    }

    fetchCompanies();
    fetchUsers();
    setState(() {});
  }

  Future<void> fetchCompanies() async {
    try {
      final companies = await _companycollectionService.getAllCompanies();

      setState(() {
        companyList = companies;
      });
    } catch (e) {
      print("Error fetching companies: $e");
    }
  }

  Future<void> register(BuildContext context) async {
    try {
      if (_validateFields(context)) {
        final userlevel = userlevelController.text.trim();
        final email = emailController.text.trim();
        final password = passwordController.text.trim();
        final username = usernameController.text.trim();

        final companyId = userlevel == 'DevelopAdmin'
            ? selectedCompanyId
            : widget.loggedInUserCompanyId;

        if (companyId == null || companyId.isEmpty) {
          await PopupMessage.show(
            context,
            title: 'Missing Company',
            message: 'Please select a company.',
            icon: Icons.error_outline,
            iconColor: Colors.orange,
            actionButtons: [
              PopupActionButton(
                label: 'OK',
                icon: Icons.check,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            autoDismiss: false,
          );

          return;
        }

        final selectedFeatures = <String>[];

        togglesState?.forEach((category, features) {
          features.forEach((featureName, enabled) {
            if (enabled) selectedFeatures.add(featureName);
          });
        });

        // Check if user already exists in your Firestore user list
        final existingUser = allUsers.firstWhere(
          (u) => u['email'] == email,
          orElse: () => {},
        );

        final updatedUser = {
          'username': username,
          'email': email,
          // 'password': passwordController.text,
          'userlevel': userlevel,
          'features': selectedFeatures,
          'companyId': companyId,
        };

        if (existingUser.isNotEmpty) {
          // 🔁 User already exists in Firestore – update Firestore only
          final uid = existingUser['uid'];

          await _usercollectionService.updateUser(uid, updatedUser);

          await PopupMessage.show(
            context,
            title: 'Updated',
            message: 'User updated successfully!',
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            actionButtons: [
              PopupActionButton(
                label: 'OK',
                icon: Icons.check,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            autoDismiss: false,
          );
        } else {
          // 🆕 User is new – create in FirebaseAuth and Firestore
          try {
            final userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
            final user = userCredential.user;
            final newUser = {
              'username': username,
              'email': email,

              'userlevel': userlevel,
              'features': selectedFeatures,
              'companyId': companyId,
            };
            if (user != null) {
              final uid = user.uid;
              newUser['uid'] = uid;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .set(newUser);

              await PopupMessage.show(
                context,
                title: 'Success',
                message: 'User registered successfully!',
                icon: Icons.check_circle_outline,
                iconColor: Colors.green,
                actionButtons: [
                  PopupActionButton(
                    label: 'OK',
                    icon: Icons.check,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
                autoDismiss: false,
              );
            }
          } on FirebaseAuthException catch (e) {
            // Handle error gracefully
            await PopupMessage.show(
              context,
              title: 'Auth Error',
              message: 'Failed to register user: ${e.message}',
              icon: Icons.error_outline,
              iconColor: Colors.red,
              actionButtons: [
                PopupActionButton(
                  label: 'OK',
                  icon: Icons.close,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              autoDismiss: false,
            );

            return;
          }
        }

        // Clear and refresh
        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        userlevelController.clear();
        togglesState?.forEach((category, features) {
          features.updateAll((key, value) => false);
        });
        setState(() {});

        await fetchUsers();
        setState(() {});
      }
    } catch (e) {
      if (context.mounted) {
        await PopupMessage.show(
          context,
          title: 'Exception',
          message: 'Error during registration:\n$e',
          icon: Icons.error,
          iconColor: Colors.redAccent,
          actionButtons: [
            PopupActionButton(
              label: 'OK',
              icon: Icons.close,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          autoDismiss: false,
        );
      }
    }
  }

  bool _validateFields(BuildContext context) {
    if (usernameController.text.trim().isEmpty) {
      _showErrorMessage(context, 'Username is required');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _showErrorMessage(context, 'Password is required');
      return false;
    }
    if (passwordController.text.trim().length < 6) {
      _showErrorMessage(context, 'Password must be at least 6 characters');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showErrorMessage(context, 'Email is required');
      return false;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      _showErrorMessage(context, 'Enter a valid email');
      return false;
    }
    return true;
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSwitch(String featureName) {
    String? categoryKey;

    for (final entry in togglesState!.entries) {
      if (entry.value.containsKey(featureName)) {
        categoryKey = entry.key;
        break;
      }
    }

    if (categoryKey == null) return SizedBox();

    bool? currentValue = togglesState?[categoryKey]![featureName]!;

    return SwitchListTile(
      title: Text(featureName),
      value: currentValue ?? false,
      onChanged: (newVal) {
        setState(() {
          togglesState?[categoryKey]![featureName] = newVal;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDevelopAdmin =
        userlevelController.text.trim() == "DevelopAdmin" ||
        initialUserLevel == "DevelopAdmin";
    final isSuperAdmin =
        userlevelController.text.trim() == "SuperAdmin" ||
        initialUserLevel == "SuperAdmin";
    final filteredUsers = isDevelopAdmin
        ? allUsers
        : isSuperAdmin
        ? allUsers
              .where(
                (user) =>
                    user['companyId'] != null &&
                    user['companyId'] == widget.loggedInUserCompanyId &&
                    user['userlevel'] != 'DevelopAdmin',
              )
              .toList()
        : [];

    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'User Registration'),
      scrollable: false,
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    widget.loggedInUserCompanyId == null
                        ? const Text("Missing logged-in user info")
                        : initialUserLevel == "DevelopAdmin"
                        ? TextField(
                            controller: userlevelController,
                            decoration: const InputDecoration(
                              labelText:
                                  "User Level (e.g., SuperAdmin, ServiceStaff,Doctor,Patient)",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) async {
                              if (value.trim() == "DevelopAdmin") {
                                await fetchCompanies();
                              }
                              setState(() {});
                            },
                          )
                        : FlexibleDropdown<String>(
                            items: const [
                              'SuperAdmin',
                              'ServiceStaff',
                              'Doctor',
                              'Patient',
                            ],
                            selectedId: userlevelController.text.isNotEmpty
                                ? userlevelController.text
                                : null,
                            label: 'User Level',
                            idSelector: (val) => val,
                            displaySelector: (val) => val,
                            onChanged: (value) async {
                              userlevelController.text = value ?? '';
                              if (value == 'DevelopAdmin') {
                                await fetchCompanies();
                              }
                              setState(() {});
                            },
                          ),

                    const SizedBox(height: 16),
                    if (isDevelopAdmin)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: companySearchController,
                            decoration: InputDecoration(
                              labelText: "Search Company",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 8),
                          if (companyList.isNotEmpty)
                            ...companyList
                                .where(
                                  (company) => company['companyname']
                                      .toLowerCase()
                                      .contains(
                                        companySearchController.text
                                            .toLowerCase(),
                                      ),
                                )
                                .map(
                                  (company) => ListTile(
                                    title: Text(company['companyname']),
                                    leading: Radio<String>(
                                      value: company['id'].toString(),
                                      groupValue: selectedCompanyId,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCompanyId = value;
                                          selectedCompanyName =
                                              company['companyname'];
                                          companySearchController.text =
                                              selectedCompanyName!;
                                        });
                                      },
                                    ),
                                  ),
                                )
                                .toList()
                          else
                            const Text("No companies found"),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company: ${widget.loggedInUserCompanyName}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Company",
                              border: OutlineInputBorder(),
                            ),
                            enabled: false,
                            controller: TextEditingController(
                              text: widget.loggedInUserCompanyName,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    if (userlevelController.text.trim().isNotEmpty ||
                        initialUserLevel.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            "Assign Features:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Parent Features', style: headerStyle),
                              ...FeatureToggles.mainMenu.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Appointment Features', style: headerStyle),
                              ...FeatureToggles.appointmentFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Patient Features', style: headerStyle),
                              ...FeatureToggles.patientFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Doctor Features', style: headerStyle),
                              ...FeatureToggles.doctorFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Billing Features', style: headerStyle),
                              ...FeatureToggles.billingFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Inventory Features', style: headerStyle),
                              ...FeatureToggles.inventoryFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Lab Features', style: headerStyle),
                              ...FeatureToggles.labFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Pharmacy Features', style: headerStyle),
                              ...FeatureToggles.pharmacyFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Report Features', style: headerStyle),
                              ...FeatureToggles.reportFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),

                              Text('Setting Features', style: headerStyle),
                              ...FeatureToggles.settingFeatures.keys.map(
                                (f) => _buildSwitch(f),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => register(context),
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
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    if ((isDevelopAdmin || isSuperAdmin) &&
                        filteredUsers.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        "Registered Users:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            (currentPage + 1) * pageSize > filteredUsers.length
                            ? filteredUsers.length - currentPage * pageSize
                            : pageSize,
                        itemBuilder: (context, index) {
                          final user =
                              filteredUsers[currentPage * pageSize + index];

                          final username = user['username'] ?? 'No Name';
                          final userLevel =
                              user['userlevel'] ?? 'Not Specified';

                          return ListTile(
                            title: Text(username),
                            subtitle: Text('Level: $userLevel'),
                            trailing: ElevatedButton(
                              onPressed: () => loadUserForEditing(user),
                              child: const Text('Edit'),
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: currentPage > 0
                                ? () => setState(() => currentPage--)
                                : null,
                            child: const Text("Previous"),
                          ),
                          Text("Page ${currentPage + 1}"),
                          TextButton(
                            onPressed:
                                (currentPage + 1) * pageSize <
                                    filteredUsers.length
                                ? () => setState(() => currentPage++)
                                : null,
                            child: const Text("Next"),
                          ),
                        ],
                      ),
                    ],
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
