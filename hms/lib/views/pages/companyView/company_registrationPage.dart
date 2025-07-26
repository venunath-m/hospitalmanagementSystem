import 'dart:async';
import 'dart:io' show File;
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:image_picker/image_picker.dart'; // Import Image Picker (For mobile platforms)
import 'package:file_picker/file_picker.dart'; // Import File Picker (For Web)
import 'package:intl/intl.dart';
import 'package:hms/constants/features_toggle.dart';
import 'package:hms/fireStore_service/companiesCollection_service.dart';
import 'dart:html' as html;

// Mobile-specific
import 'dart:io' as io;

import 'package:shared_preferences/shared_preferences.dart';

class CompanyRegistrationPage extends StatefulWidget {
  const CompanyRegistrationPage({super.key});

  @override
  CompanyRegistrationPageState createState() => CompanyRegistrationPageState();
}

class CompanyRegistrationPageState extends State<CompanyRegistrationPage> {
  final companynameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final gstinController = TextEditingController();
  final websiteController = TextEditingController();
  Map<String, Map<String, bool>>? togglesState;
  final CompanycollectionService _companycollectionService =
      CompanycollectionService();
  String? editingCompanyId;
  String? _cachedCompanyId;
  final bankNameController = TextEditingController();
  final accountNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final ifscCodeController = TextEditingController();
  final branchController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipcodeController = TextEditingController();

  final TextStyle headerStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey,
  );

  final countryController = TextEditingController();
  final registeredDateController = TextEditingController();
  final renewalDateController = TextEditingController();
  final periodController = TextEditingController();
  DateTime? registeredDate;
  DateTime? renewalDate;

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    bool isRegistered,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Combine with current time for full datetime
      final fullDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
        DateTime.now().millisecond,
      );

      setState(() {
        controller.text = fullDate.toIso8601String(); // for display only
        if (isRegistered) {
          registeredDate = fullDate;
        } else {
          renewalDate = fullDate;
        }
      });
    }
  }

  List<Map<String, dynamic>> companies = [];
  int pageSize = 5;

  int currentPage = 0;
  DocumentSnapshot? lastDoc;
  DocumentSnapshot? firstDocOnPage;
  bool hasNext = true;
  bool hasPrevious = false;

  XFile? logoImage; // Store the picked image
  String logoUrl = ''; // URL for the logo to store in Firestore
  bool hasUploadedImage = false; // Track whether the image is uploaded

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
    getLoggedInCompanyId();
    togglesState = {};
    FeatureToggles.categorized.forEach((category, features) {
      togglesState?[category] = Map<String, bool>.from(features);
    });
  }

  Future<void> _fetchCompanies({bool next = true}) async {
    QuerySnapshot snapshot;

    if (next && lastDoc != null) {
      snapshot = await _companycollectionService.getCompanies(
        limit: pageSize,
        startAfter: lastDoc,
      );
    } else if (!next && firstDocOnPage != null) {
      snapshot = await _companycollectionService.getCompaniesReverse(
        limit: pageSize,
        endBefore: firstDocOnPage,
      );
    } else {
      snapshot = await _companycollectionService.getCompanies(limit: pageSize);
    }

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        companies = snapshot.docs.map((doc) {
          return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        }).toList();

        firstDocOnPage = snapshot.docs.first;
        lastDoc = snapshot.docs.last;

        if (next) {
          currentPage++;
          hasPrevious = true;
        } else {
          currentPage = currentPage > 0 ? currentPage - 1 : 0;
          hasNext = true;
        }

        hasNext = snapshot.docs.length == pageSize;
      });
    } else {
      setState(() {
        if (next) hasNext = false;
        if (!next && currentPage > 0) currentPage--;
      });
    }
  }

  void _clearForm() {
    companynameController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    websiteController.clear();
    gstinController.clear();
    bankNameController.clear();
    accountNameController.clear();
    accountNumberController.clear();
    ifscCodeController.clear();
    branchController.clear();
    cityController.clear();
    countryController.clear();
    registeredDateController.clear();
    renewalDateController.clear();
    periodController.clear();
    stateController.clear();
    zipcodeController.clear();
    logoImage = null;
    logoUrl = '';
    editingCompanyId = null;
  }

  void _editCompany(Map<String, dynamic> company) {
    togglesState?.forEach((category, features) {
      features.updateAll((key, value) => false);
    });

    if (company['featuresEnabled'] != null) {
      List<dynamic> enabledFeatures = company['featuresEnabled'];

      for (final feature in company['featuresEnabled']) {
        togglesState?.forEach((category, features) {
          if (features.containsKey(feature)) {
            features[feature] = true;
          }
        });
      }
    }
    companynameController.text = company['companyname'];
    websiteController.text = company['webSite'];
    phoneController.text = company['phone'];
    emailController.text = company['email'];
    addressController.text = company['address'] ?? '';
    gstinController.text = company['gstin'] ?? '';
    logoUrl = company['logoUrl'] ?? '';
    bankNameController.text = company['bankName'] ?? '';
    accountNameController.text = company['accountName'] ?? '';
    accountNumberController.text = company['accountNumber'] ?? '';
    ifscCodeController.text = company['ifscCode'] ?? '';
    branchController.text = company['branch'] ?? '';
    cityController.text = company['city'] ?? '';
    stateController.text = company['state'] ?? '';
    zipcodeController.text = company['zip'] ?? '';
    editingCompanyId = company['id'];
    countryController.text = company['country'] ?? '';

    // Convert Timestamp to DateTime and format to string
    DateFormat dateFormat = DateFormat(
      'yyyy-MM-dd',
    ); // or your preferred format

    if (company['registeredDate'] != null) {
      registeredDate = (company['registeredDate'] as Timestamp).toDate();
      registeredDateController.text = dateFormat.format(registeredDate!);
    } else {
      registeredDate = null;
      registeredDateController.text = '';
    }

    if (company['renewalDate'] != null) {
      renewalDate = (company['renewalDate'] as Timestamp).toDate();
      renewalDateController.text = dateFormat.format(renewalDate!);
    } else {
      renewalDate = null;
      renewalDateController.text = '';
    }

    periodController.text = company['period'] ?? '';
  }

  Future<String> getLoggedInCompanyId() async {
    if (_cachedCompanyId != null && _cachedCompanyId!.isNotEmpty) {
      return _cachedCompanyId!;
    }
    final prefs = await SharedPreferences.getInstance();
    _cachedCompanyId = prefs.getString('companyId') ?? '';
    return _cachedCompanyId!;
  }

  // Method to pick an image depending on the platform
  void pickImageWeb(String companyId) {
    if (companyId.isEmpty) {
      companyId = _cachedCompanyId ?? '';
    }
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        uploadImage(file, companyId: companyId).then((url) {
          setState(() {
            logoUrl = url ?? '';
            hasUploadedImage = true;
          });
        });
      }
    });
  }

  Future<String?> uploadImage(dynamic file, {required String companyId}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not authenticated');
      }
      if (companyId.isEmpty) {
        companyId = _cachedCompanyId ?? '';
      }
      final fileName =
          'company_logos/$companyId/${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask;

      if (kIsWeb) {
        final reader = html.FileReader();
        final completer = Completer<String?>();

        reader.readAsArrayBuffer(file as html.File);
        reader.onLoadEnd.listen((event) async {
          final bytes = reader.result as Uint8List;

          final metadata = SettableMetadata(
            contentType: file.type ?? 'image/png',
            customMetadata: {'companyId': companyId},
          );

          final snapshot = await ref.putData(bytes, metadata);
          final downloadUrl = await snapshot.ref.getDownloadURL();
          completer.complete(downloadUrl);
        });

        reader.onError.listen((event) {
          completer.completeError("Failed to read file: ${reader.error}");
        });

        return completer.future;
      } else {
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'companyId': companyId},
        );
        uploadTask = ref.putFile(file as io.File, metadata);
        final snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _registerCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId') ?? '';
    if (companynameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        gstinController.text.isEmpty ||
        countryController.text.isEmpty ||
        registeredDateController.text.isEmpty ||
        renewalDateController.text.isEmpty ||
        periodController.text.isEmpty) {
      if (mounted) {
        await PopupMessage.show(
          context,
          title: "Validation Error",
          message: "Please fill in all required fields.",
          icon: Icons.error_outline,
          iconColor: Colors.red,
          actionButtons: [
            PopupActionButton(
              label: "OK",
              icon: Icons.check,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          autoDismiss: false, // So user must tap OK
        );
      }
      return;
    }

    try {
      String? uploadedLogoUrl = logoUrl;

      if (logoImage != null) {
        File logoFile = File(logoImage!.path);
        uploadedLogoUrl = await uploadImage(logoFile, companyId: companyId);
      }

      final enabledFeatures = <String>[];

      togglesState?.forEach((category, features) {
        features.forEach((featureName, enabled) {
          if (enabled) enabledFeatures.add(featureName);
        });
      });
      final data = {
        'companyname': companynameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'gstin': gstinController.text,
        'logoUrl': uploadedLogoUrl,
        'webSite': websiteController.text,
        'city': cityController.text,
        'state': stateController.text,
        'zip': zipcodeController.text,
        'featuresEnabled': enabledFeatures,
        'bankName': bankNameController.text,
        'accountName': accountNameController.text,
        'accountNumber': accountNumberController.text,
        'ifscCode': ifscCodeController.text,
        'branch': branchController.text,
        'country': countryController.text,
        'registeredDate': registeredDate,
        'renewalDate': renewalDate,
        'period': periodController.text,
      };

      if (editingCompanyId == null) {
        await _companycollectionService.addCompany(data);
        if (mounted) {
          await PopupMessage.show(
            context,
            title: "Success",
            message: "Company registered successfully!",
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            actionButtons: [
              PopupActionButton(
                label: "OK",
                icon: Icons.check,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            autoDismiss: false, // Require user to tap OK
          );
        }
      } else {
        await _companycollectionService.updateCompany(editingCompanyId!, data);
        if (mounted) {
          await PopupMessage.show(
            context,
            title: "Success",
            message: "Company updated successfully!",
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            actionButtons: [
              PopupActionButton(
                label: "OK",
                icon: Icons.check,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            autoDismiss: false, // Require user to tap OK
          );
        }
      }

      _clearForm();
      _fetchCompanies();
    } catch (e) {
      print("Error in _registerCompany: $e");
      if (mounted) {
        await PopupMessage.show(
          context,
          title: "Error",
          message:
              "Failed to register/update company. Please try again.\nError: $e",
          icon: Icons.error_outline,
          iconColor: Colors.red,
          actionButtons: [
            PopupActionButton(
              label: "OK",
              icon: Icons.close,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          autoDismiss: false, // Require user action
        );
      }
    }
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
    return Scaffold(
      appBar: AppBar(title: Text('Company Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Registration Form
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Company Name Field
                        TextField(
                          controller: companynameController,
                          decoration: InputDecoration(
                            labelText: "Company Name",
                          ),
                        ),
                        SizedBox(height: 8),
                        // Email Field
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(labelText: "Email"),
                        ),
                        SizedBox(height: 8),
                        // Website Field
                        TextField(
                          controller: websiteController,
                          decoration: InputDecoration(labelText: "Website"),
                        ),
                        SizedBox(height: 8),
                        // Phone Field
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: "Contact Number",
                          ),
                        ),
                        SizedBox(height: 8),
                        // Address Field
                        TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: "Company Address",
                          ),
                        ),
                        SizedBox(height: 8),
                        // GSTIN Field
                        TextField(
                          controller: gstinController,
                          decoration: InputDecoration(labelText: "GSTIN"),
                        ),

                        SizedBox(height: 8),
                        // Email Field
                        TextField(
                          controller: cityController,
                          decoration: InputDecoration(labelText: "City"),
                        ),
                        SizedBox(height: 8),
                        // Website Field
                        TextField(
                          controller: stateController,
                          decoration: InputDecoration(labelText: "State"),
                        ),
                        SizedBox(height: 8),
                        // Phone Field
                        TextField(
                          controller: zipcodeController,
                          decoration: InputDecoration(labelText: "ZipCode"),
                        ),
                        SizedBox(height: 8),
                        SizedBox(height: 8),
                        // Email Field
                        TextField(
                          controller: countryController,
                          decoration: InputDecoration(labelText: "Country"),
                        ),
                        SizedBox(height: 8),
                        // Website Field
                        TextField(
                          controller: registeredDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Registered Date",
                            hintText: "Pick Date",
                          ),
                          onTap: () => _selectDate(
                            context,
                            registeredDateController,
                            true,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Renewal Date
                        TextField(
                          controller: renewalDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Renewal Date",
                            hintText: "Pick Date",
                          ),
                          onTap: () => _selectDate(
                            context,
                            renewalDateController,
                            false,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Address Field
                        TextField(
                          controller: periodController,
                          decoration: InputDecoration(labelText: "Period"),
                        ),
                        // Address Field
                        TextField(
                          controller: bankNameController,
                          decoration: InputDecoration(labelText: "Bank Name"),
                        ),
                        SizedBox(height: 8),
                        // GSTIN Field
                        TextField(
                          controller: accountNameController,
                          decoration: InputDecoration(labelText: "AccountName"),
                        ),
                        TextField(
                          controller: accountNumberController,
                          decoration: InputDecoration(
                            labelText: "AccountNumber",
                          ),
                        ),
                        SizedBox(height: 8),
                        // Address Field
                        TextField(
                          controller: ifscCodeController,
                          decoration: InputDecoration(labelText: "IfscCode"),
                        ),
                        SizedBox(height: 8),
                        // GSTIN Field
                        TextField(
                          controller: branchController,
                          decoration: InputDecoration(labelText: "Branch"),
                        ),
                        SizedBox(height: 16),
                        // Logo Upload Button
                        GestureDetector(
                          onTap: () => pickImageWeb(_cachedCompanyId ?? ''),
                          child: Container(
                            color: Colors.blue[50],
                            height: 80,
                            width: 80,
                            child: logoImage == null
                                ? Icon(Icons.add_a_photo, size: 40)
                                : Image.file(File(logoImage!.path)),
                          ),
                        ),

                        // Display the uploaded logo image below the button
                        if (hasUploadedImage && logoUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.network(
                              logoUrl, // Display uploaded image
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(height: 16),
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

                                Text(
                                  'Appointment Features',
                                  style: headerStyle,
                                ),
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
                        SizedBox(height: 16),
                        // Register Button
                        ElevatedButton(
                          onPressed: _registerCompany,
                          child: Text(
                            editingCompanyId == null ? "Register" : "Update",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Companies List
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: companies.length,
                      itemBuilder: (context, index) {
                        final company = companies[index];
                        return Card(
                          child: ListTile(
                            title: Text(company['companyname']),
                            subtitle: Text(
                              '${company['email']} | ${company['phone']}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editCompany(company),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: hasPrevious
                              ? () => _fetchCompanies(next: false)
                              : null,
                          child: Text("Previous"),
                        ),
                        Text("Page ${currentPage + 1}"),
                        ElevatedButton(
                          onPressed: hasNext
                              ? () => _fetchCompanies(next: true)
                              : null,
                          child: Text("Next"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
