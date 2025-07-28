import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hms/service_utilities/invoices/sales_invoice.dart';
import 'package:hms/dbservices/companiesModel.dart';
import 'package:hms/fireStore_service/accountBookCollection_service.dart';
import 'package:hms/fireStore_service/companiesCollection_service.dart';
import 'package:hms/fireStore_service/customerLedger_service.dart';
import 'package:hms/fireStore_service/customer_service.dart';
import 'package:hms/fireStore_service/itemsCollection_service.dart';
import 'package:hms/fireStore_service/saleDetailCollection_service.dart';
import 'package:hms/fireStore_service/salesSummary_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesEntryPage extends StatefulWidget {
  final Map<String, dynamic>? orderSummary;
  final List<Map<String, dynamic>>? orderDetails;
  final bool? fromWhatsappOrder;
  const SalesEntryPage({
    Key? key,
    this.orderSummary,
    this.orderDetails,
    this.fromWhatsappOrder = false,
  }) : super(key: key);

  @override
  _SalesEntryPageState createState() => _SalesEntryPageState();
}

class _SalesEntryPageState extends State<SalesEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemFormKey = GlobalKey<FormState>();
  String? userId;
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> saleItems = [];
  final TextEditingController customerSearchController =
      TextEditingController();
  Map<String, dynamic>? selectedCustomer;
  Map<String, dynamic>? selectedItem;
  String? selectedItemId;
  String selectedPaymentMode = 'Cash';
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController paidAmountController = TextEditingController();
  TextEditingController taxPercentageController = TextEditingController();
  TextEditingController billingAddressController = TextEditingController();
  TextEditingController shippingAddressController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController _controller = TextEditingController();
  final CustomerledgerService _customerledgerService = CustomerledgerService();
  final SaledetailcollectionService _saledetailcollectionService =
      SaledetailcollectionService();
  final CustomerService _customerService = CustomerService();
  final SalessummaryService _salessummaryService = SalessummaryService();
  final ItemsCollectionService _itemsCollectionService =
      ItemsCollectionService();
  final AccountBookCollectionService _accountBookCollectionService =
      AccountBookCollectionService();
  DateTime selectedDate = DateTime.now();

  double get totalAmount =>
      saleItems.fold(0, (sum, item) => sum + item['price'] * item['quantity']);
  double get totalTax =>
      saleItems.fold(0, (sum, item) => sum + (item['taxAmount'] ?? 0.0));
  String? companyCountry;
  bool? isIndianCompany;
  Company? _company;
  final CompanycollectionService _companyService = CompanycollectionService();

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    _fetchCompany();
    if (widget.fromWhatsappOrder == true) {
      selectedPaymentMode = 'Bank'; //  Override payment mode
    }
    if (widget.orderSummary != null && widget.orderDetails != null) {
      final summary = widget.orderSummary!;
      final details = widget.orderDetails!;

      // ✅ Initialize selectedCustomer before accessing it
      selectedCustomer = {
        'name': summary['customerName'] ?? '',
        'contact': summary['customerPhone'] ?? '',
        'email': '',
        'address': '',
      };

      //  Set payment mode safely
      selectedPaymentMode = summary['paymentMode'] ?? 'Cash';

      //  Set billing date safely
      selectedDate = summary['billingDate'] is DateTime
          ? summary['billingDate']
          : DateTime.now();

      //  Safely map order details
      prepareSaleItemsFromOrderDetails(details).then((_) {
        setState(() {
          if (selectedPaymentMode == 'Credit') {
            paidAmountController.text =
                summary['paidAmount']?.toString() ?? '0';
          }
        });
      });
      fetchCustomerFromSummary();
    }
  }

  Future<void> fetchCustomerFromSummary() async {
    try {
      if (widget.orderSummary == null) return;

      final summary = widget.orderSummary!;

      // Try to find by contact first
      final querySnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('contact', isEqualTo: summary['customerPhone'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final customer = querySnapshot.docs.first.data();

        setState(() {
          selectedCustomer = customer;
          customerSearchController.text = selectedCustomer?['name'] ?? '';
          billingAddressController.text = customer['address'] ?? '';
          shippingAddressController.text = customer['shippingAddress'] ?? '';
        });
      } else {
        // Try by name
        final nameQuery = await FirebaseFirestore.instance
            .collection('customers')
            .where('name', isEqualTo: summary['customerName'])
            .get();

        if (nameQuery.docs.isNotEmpty) {
          final customer = nameQuery.docs.first.data();

          setState(() {
            selectedCustomer = customer;
            billingAddressController.text = customer['address'] ?? '';
            shippingAddressController.text = customer['shippingAddress'] ?? '';
          });
        } else {
          debugPrint('Customer not found in Firestore.');
        }
      }
    } catch (e, stack) {
      debugPrint('🔥 Error in fetchCustomerFromSummary(): $e');
      debugPrint('🔥 StackTrace: $stack');
    }
  }

  Future<void> prepareSaleItemsFromOrderDetails(
    List<Map<String, dynamic>> details,
  ) async {
    final itemService = ItemsCollectionService();

    saleItems = await Future.wait(
      details.map((item) async {
        final productName = item['productName'] ?? '';
        double quantity = (item['quantity'] ?? 1).toDouble();

        // Fetch item by name
        Map<String, dynamic>? fetchedItem = await itemService.getItemByName(
          productName,
        );
        // If item does not exist, insert default item
        String itemId;
        if (fetchedItem == null) {
          final defaultItem = {
            'name': productName,
            'rate': 0.0,
            'tax': 0,
            'hsnCode': '',
            'cgst': 0,
            'sgst': 0,
            'igst': 0,
            'stock': 0,
            'itemCost': 0,
            'unit': 'Nos',
          };

          itemId = await itemService.addItem(defaultItem);
          fetchedItem = {'id': itemId, ...defaultItem};
        } else {
          itemId = fetchedItem['id']; // Make sure ID is kept
        }

        // Always use fetched rate if present
        double fetchedRate = (fetchedItem['rate'] ?? 0.0).toDouble();

        // Only use incoming price if it is a valid number
        double? incomingPrice;
        if (item['price'] is num && (item['price'] as num) > 0) {
          incomingPrice = (item['price'] as num).toDouble();
        } else {
          incomingPrice = null;
        }

        double price = incomingPrice ?? fetchedRate;
        // Tax logic
        final taxRate = (fetchedItem['tax'] ?? 0.0).toDouble();
        double? incomingTaxAmount = (item['taxAmount'] is num)
            ? item['taxAmount'].toDouble()
            : null;

        double taxAmount =
            incomingTaxAmount ?? (price * quantity * taxRate / 100);

        return {
          'itemId': itemId,
          'itemName': productName,
          'quantity': quantity,
          'price': price,
          'taxAmount': taxAmount,
          'itemTotalAmount': (price * quantity) + taxAmount,
        };
      }).toList(),
    );
  }

  Future<Map<String, dynamic>?> fetchCustomerByPhone(String localPhone) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('customers')
        .where('contact', isEqualTo: localPhone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {
        'customerId': doc.id,
        'name': doc['name'],
        'balance': doc['balance'],
        'companyId': doc['companyId'],
        'gstin': doc['gstin'],
        'shippingAddress': doc['shippingAddress'],
        'userId': doc['userId'],
        'contact': doc['contact'],
        'address': doc['address'], // if you want to include this too
      };
    }
    return null;
  }

  String extractLocalPhoneNumber(String phone) {
    String digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 10 && digitsOnly.startsWith('91')) {
      return digitsOnly.substring(2); // remove '91' prefix
    }
    return digitsOnly;
  }

  String customerId = '';
  void prefillCustomerData(String rawPhoneFromOrder) async {
    String localPhone = extractLocalPhoneNumber(rawPhoneFromOrder);
    final prefs = await SharedPreferences.getInstance();
    String companyId = prefs.getString('companyId').toString();
    double balance;
    String phoneNo = localPhone;
    String gstinFetched = '';
    final customerData = await fetchCustomerByPhone(localPhone);

    if (customerData != null) {
      setState(() {
        selectedCustomer!['name'] = customerData['name'] ?? '';
        customerId =
            customerData['customerId'] ??
            ''; // store if you want to use it later
        balance = customerData['balance'] ?? 0;
        companyId = customerData['companyId'] ?? '';
        gstinFetched = customerData['gstin'] ?? '';
        shippingAddressController.text = customerData['shippingAddress'] ?? '';
        // fill other fields as needed
      });
    } else {
      // fallback: maybe fill name from order summary if no customer found
      setState(() {
        customerSearchController.text =
            selectedCustomer!['name'] ?? customerData!['name'] ?? '';
        selectedCustomer!['name'] = ''; // or from order summary if you have
        customerId = customerData!['customerId'] ?? '';
        ;
      });
    }
  }

  Future<void> _fetchCompany() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      // Fetching company data from the service
      final companyData = await _companyService.getCompanyById(companyId!);

      if (companyData != null) {
        // Assuming Company.fromJson method correctly parses the fields from the response
        _company = Company.fromJson(companyData);

        // Extracting the specific fields from the company data
        companyCountry =
            _company?.country ??
            "Unknown Country"; // Providing a default value if null

        isIndianCompany = companyCountry?.toLowerCase() == 'india';
      } else {
        print("No company data found for ID: $companyId");
      }
    } catch (e) {
      print("Error loading company: $e");
    }
  }

  String? getEffectiveAddress(String? customerValue, String controllerValue) {
    final trimmedCustomer = customerValue?.trim();
    final trimmedController = controllerValue.trim();

    if (trimmedCustomer != null && trimmedCustomer.isNotEmpty) {
      return trimmedCustomer;
    } else if (trimmedController.isNotEmpty) {
      return trimmedController;
    } else {
      return null;
    }
  }

  Future<void> fetchInitialData() async {
    final prefs = await SharedPreferences.getInstance(); //  Define prefs here
    userId = prefs.getString('userId');
    final customerRecords = await _customerService.getAllCustomers();
    final itemRecords = await _itemsCollectionService.getAllItems();

    setState(() {
      customers = customerRecords.map((e) {
        return {
          'id': e['id'], // Use the Firestore document ID instead of 'key'
          ...e, // Include the rest of the data
        };
      }).toList();

      items = itemRecords.map((e) {
        return {
          'id': e['id'], // Use the Firestore document ID instead of 'key'
          ...e, // Include the rest of the data
        };
      }).toList();
    });
  }

  void addItemToSale() async {
    if (_itemFormKey.currentState?.validate() != true || selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all item fields correctly.')),
      );
      return;
    }

    double quantity = double.parse(quantityController.text);

    var existingItem = await _itemsCollectionService.getItemByName(
      selectedItem?['name'] ?? '',
    );

    if (existingItem == null) {
      selectedItemId = await _itemsCollectionService.addItem({
        'name': selectedItem?['name'] ?? '',
        'unit': '',
        'rate': 0.0, // You can decide default
        'tax': 0.0,
        'cgst': 0,
        'sgst': 0,
        'igst': 0,
        'hsnCode': 0,
        'subCategory': '',
        'itemCost': 0,
        'mrp': 0,
      });
    } else {
      selectedItemId = existingItem['id'];
    }

    double price = priceController.text.isNotEmpty
        ? double.parse(priceController.text)
        : (selectedItem?['rate'] ?? 0.0).toDouble();

    double taxPercentage = taxPercentageController.text.isNotEmpty
        ? double.parse(taxPercentageController.text)
        : (selectedItem?['tax'] ?? 0.0).toDouble();

    double taxAmount = (price * quantity * taxPercentage / 100);
    double itemTotalAmount = (price * quantity) + taxAmount;

    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    if (isIndianCompany!) {
      cgst = taxPercentage / 2;
      sgst = taxPercentage / 2;
    } else {
      igst = taxPercentage;
    }

    saleItems.add({
      'itemId': selectedItemId,
      'itemName': selectedItem!['name'],
      'quantity': quantity,
      'price': price,
      'taxPercentage': taxPercentage,
      'cgst': cgst,
      'sgst': sgst,
      'igst': igst,
      'taxAmount': taxAmount,
      'itemTotalAmount': itemTotalAmount,
    });

    setState(() {
      selectedItem = null;
      quantityController.clear();
      priceController.clear();
      taxPercentageController.clear();
      stockController.clear();
    });
  }

  Future<String> generateUniqueBillNo() async {
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');
    final companyName = prefs.getString('companyName');
    if (companyId == null || companyName == null) {
      throw Exception("Company ID or Company Name not found.");
    }
    final companyPrefix = companyName.substring(0, 2).toUpperCase();
    final db = FirebaseFirestore.instance;

    // Today's date in ddMMyyyy format
    final now = DateTime.now();
    final dateStr =
        "${now.day.toString().padLeft(2, '0')}"
        "${now.month.toString().padLeft(2, '0')}"
        "${now.year}";

    final prefix = "$companyPrefix-$dateStr";

    // Fetch documents with the current date and company prefix in billNo
    final snapshotSales = await db
        .collection('sales_summary')
        .where('companyId', isEqualTo: companyId)
        .where(
          'billEntryDate',
          isGreaterThanOrEqualTo: DateTime(
            now.year,
            now.month,
            now.day,
          ).toIso8601String(),
        )
        .get();

    final snapshotDelivery = await db
        .collection('delivery_sales_summary')
        .where('companyId', isEqualTo: companyId)
        .where(
          'billEntryDate',
          isGreaterThanOrEqualTo: DateTime(
            now.year,
            now.month,
            now.day,
          ).toIso8601String(),
        )
        .get();

    // Count all matching docs for the day across both collections
    final totalCount = snapshotSales.size + snapshotDelivery.size;

    final billNo = "$prefix-${totalCount + 1}";

    return billNo;
  }

  Future<void> saveSale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> companyFeatures = [];

      userId = prefs.getString('userId');
      final featuresString = prefs.getString('companyFeatures') ?? '[]';
      companyFeatures = List<String>.from(jsonDecode(featuresString));

      final userFeaturesString = prefs.getString('userFeatures');
      if (userFeaturesString == null) {
        throw Exception('User features not found in preferences');
      }

      final List<dynamic> userFeatures = jsonDecode(userFeaturesString);

      final hasWhatsAppOrder =
          companyFeatures.contains("WhatsAppOrder") &&
          userFeatures.contains("WhatsAppOrder");

      if (_formKey.currentState?.validate() != true ||
          selectedCustomer == null ||
          saleItems.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please complete all required fields before saving.',
              ),
            ),
          );
        }
        return;
      }

      String? customerId;
      try {
        // Get or add customer
        var existingCustomer = await _customerService
            .getCustomerByNameAndAddress(
              selectedCustomer?['name'] ?? '',
              selectedCustomer?['address'] ?? '',
            );

        final customerDataEntries = {
          'name': selectedCustomer?['name'] ?? '',
          'address': getEffectiveAddress(
            selectedCustomer?['address'],
            billingAddressController.text,
          ),
          'shippingAddress': getEffectiveAddress(
            selectedCustomer?['shippingAddress'],
            shippingAddressController.text,
          ),
          'contact': null,
          'gstin': null,
          'balance': 0.0,
        };

        if (existingCustomer == null) {
          customerId = await _customerService.addCustomer(customerDataEntries);
        } else {
          customerId = existingCustomer['id'];
        }
      } catch (e) {
        print("Error while fetching or adding customer: $e");
        rethrow;
      }

      double grandTotal = totalAmount + totalTax;
      double paidAmount = ['Credit'].contains(selectedPaymentMode)
          ? double.tryParse(paidAmountController.text) ?? 0.0
          : grandTotal;
      double balanceAmount = grandTotal - paidAmount;
      final saleStatus = selectedPaymentMode == 'Credit' ? 'pending' : 'paid';

      final billNo = await generateUniqueBillNo();
      String? orderIdNumber = widget.orderSummary?['orderId'] ?? '';

      String saleId;
      try {
        saleId = await _salessummaryService.addSalesSummary({
          'customerId': customerId,
          'customerName': selectedCustomer?['name'] ?? 'Unknown',
          'billEntryDate': selectedDate.toIso8601String(),
          'total': totalAmount,
          'taxTotal': totalTax,
          'grandTotal': grandTotal,
          'paymentMode': selectedPaymentMode,
          'paidAmount': paidAmount,
          'balance': balanceAmount,
          'status': saleStatus,
          'billNo': billNo,
          'orderId': orderIdNumber,
          'deliveryDate': selectedDate.toIso8601String(),
          'deliveryStatus': 'Pending',
        });
      } catch (e) {
        print("Error while adding sales summary: $e");
        rethrow;
      }

      try {
        for (var item in saleItems) {
          final quantity = double.tryParse(item['quantity'].toString()) ?? 0;
          await _saledetailcollectionService.addSalesDetail({
            'salesId': saleId,
            ...item,
            'total': item['price'] * quantity,
          });
          await _itemsCollectionService.reduceItemStock(
            item['itemId'],
            quantity,
          );
        }
      } catch (e) {
        print("Error while saving sales details or reducing stock: $e");
        rethrow;
      }

      final companyId = prefs.getString('companyId');

      String salesGroupId;
      try {
        final groupSnapshot = await FirebaseFirestore.instance
            .collection('account_groups')
            .where('headName', isEqualTo: 'Sales Group A/C')
            .where('companyId', isEqualTo: companyId)
            .limit(1)
            .get();

        if (groupSnapshot.docs.isNotEmpty) {
          salesGroupId = groupSnapshot.docs.first.id;
        } else {
          final newGroup = await FirebaseFirestore.instance
              .collection('account_groups')
              .add({
                'headName': 'Sales Group A/C',
                'description': 'Sales Group',
                'accountType': 'Income',
                'companyId': companyId,
                'userId': userId,
              });
          salesGroupId = newGroup.id;
        }
      } catch (e) {
        print("Error ensuring Sales Group A/C exists: $e");
        rethrow;
      }

      String salesAccountHeadId;
      try {
        final headSnapshot = await FirebaseFirestore.instance
            .collection('account_heads')
            .where('headName', isEqualTo: 'Sales A/C')
            .where('companyId', isEqualTo: companyId)
            .limit(1)
            .get();

        if (headSnapshot.docs.isNotEmpty) {
          salesAccountHeadId = headSnapshot.docs.first.id;
        } else {
          final newHead = await FirebaseFirestore.instance
              .collection('account_heads')
              .add({
                'headName': 'Sales A/C',
                'description': 'Sales A/C',
                'selectedGroup': salesGroupId,
                'companyId': companyId,
                'userId': userId,
              });
          salesAccountHeadId = newHead.id;
        }
      } catch (e) {
        print("Error ensuring Sales A/C exists: $e");
        rethrow;
      }

      try {
        await _accountBookCollectionService.addAccountBookEntry({
          'transactionType': selectedPaymentMode,
          'debit': selectedPaymentMode == 'Credit' ? paidAmount : 0.0,
          'credit': ['Cash', 'Debit', 'Bank'].contains(selectedPaymentMode)
              ? paidAmount
              : 0.0,
          'description':
              'Sales to ${selectedCustomer!['name']} ($selectedPaymentMode)',
          'accountId': salesAccountHeadId,
          'date': selectedDate.toIso8601String(),
          'paymentMode': selectedPaymentMode,
        });
      } catch (e) {
        print("Error adding account book entry: $e");
        rethrow;
      }

      if (selectedPaymentMode == 'Credit') {
        try {
          await _customerledgerService.addCustomerLedgerEntry(
            entry: {
              'customerId': customerId,
              'name': selectedCustomer?['name'],
              'date': selectedDate.toIso8601String(),
              'description': 'Credit Sale - Bill No. $billNo',
              'debit': grandTotal,
              'credit': 0.0,
              'type': 'Debit',
            },
          );

          if (paidAmount > 0) {
            await _customerledgerService.addCustomerLedgerEntry(
              entry: {
                'customerId': customerId,
                'name': selectedCustomer?['name'],
                'date': selectedDate.toIso8601String(),
                'description': 'Payment Received for Bill No. $billNo',
                'debit': 0.0,
                'credit': paidAmount,
                'type': 'Credit',
              },
            );
          }

          await _customerService.updateCustomerBalance(
            customerId!,
            balanceAmount,
          );
        } catch (e) {
          print("Error adding customer ledger entries: $e");
          rethrow;
        }
      }

      if (!context.mounted) return;

      final summaryData = {
        'id': saleId,
        'customerId': customerId,
        'customerName': selectedCustomer?['name'] ?? 'Unknown',
        'billEntryDate': selectedDate.toIso8601String(),
        'total': totalAmount,
        'taxTotal': totalTax,
        'grandTotal': grandTotal,
        'paymentMode': selectedPaymentMode,
        'paidAmount': paidAmount,
        'balance': balanceAmount,
        'status': saleStatus,
        'billNo': billNo,
      };

      final detailsData = saleItems.map((item) {
        return {
          ...item,
          'total': item['price'] * item['quantity'],
          'salesId': saleId,
        };
      }).toList();

      await Future.delayed(const Duration(milliseconds: 2));

      if (!context.mounted) return;

      CustomMessageDialogPrint.showWithActions(
        context,
        title: 'Sale Saved',
        message:
            'The sale was saved successfully. Do you want to print the invoice?',
        onPrint: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewKotInvoicePageSales(
                type: 'sales',
                summaryData: summaryData,
                details: detailsData,
              ),
            ),
          );
        },
        onBack: () {
          Navigator.pop(context);
        },
      );

      setState(() {
        selectedCustomer = null;
        selectedItem = null;
        saleItems.clear();
        selectedDate = DateTime.now();
        selectedPaymentMode = 'Cash';
        paidAmountController.clear();
      });
    } catch (e, stackTrace) {
      print("🔥🔥🔥 Error during saveSale: $e");
      print(stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving sale: $e')));
      }
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _deleteItem(int index) {
    setState(() {
      saleItems.removeAt(index);
    });
  }

  void _editItem(int index) {
    final item = saleItems[index];

    // Example: Open dialog to edit item (customize as needed)
    showDialog(
      context: context,
      builder: (context) {
        final qtyController = TextEditingController(
          text: item['quantity'].toString(),
        );
        final priceController = TextEditingController(
          text: item['price'].toString(),
        );

        return AlertDialog(
          title: Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  saleItems[index]['quantity'] =
                      int.tryParse(qtyController.text) ?? item['quantity'];
                  saleItems[index]['price'] =
                      double.tryParse(priceController.text) ?? item['price'];

                  // Recalculate total
                  final qty = saleItems[index]['quantity'];
                  final price = saleItems[index]['price'];
                  final tax = saleItems[index]['taxAmount'] ?? 0.0;

                  saleItems[index]['itemTotalAmount'] = (qty * price) + tax;
                });
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.account_balance_wallet, color: Colors.indigo),
            SizedBox(width: 8),
            Text(
              'Billing',
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.indigo),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: 10),
              CustomTextFieldSearchable(
                label: 'Enter Customer',
                controller: customerSearchController,
                searchCallback: (query) async {
                  // Fetch customers based on search query
                  return customers
                      .where(
                        (customer) => (customer['name'] ?? '')
                            .toLowerCase()
                            .contains(query.toLowerCase()),
                      )
                      .toList();
                },
                onItemSelected: (item) {
                  setState(() {
                    selectedCustomer = item;
                    billingAddressController.text = item['address'];
                    shippingAddressController.text = item['shippingAddress'];
                    customerSearchController.text = item['name'] ?? '';
                  });
                },
                onManualEntry: (input) async {
                  // When manual entry is made, update selectedCustomer
                  setState(() {
                    selectedCustomer = {'name': input}; // Manually set name
                  });
                  return {
                    'name': input,
                  }; // Return the newly created customer map
                },
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: billingAddressController,
                      decoration: InputDecoration(
                        labelText: 'Billing Address',
                        labelStyle: TextStyle(
                          color: Colors.blue,
                        ), // Set label text color to blue
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter billing address';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: shippingAddressController,
                      decoration: InputDecoration(
                        labelText: 'Shipping Address',
                        labelStyle: TextStyle(
                          color: Colors.blue,
                        ), // Set label text color to blue
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Enter shipping address';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextButton(onPressed: pickDate, child: Text("Change Date")),
              Row(
                children: [
                  Text(
                    "Bill Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Payment Mode',
                  labelStyle: TextStyle(
                    color: Colors.blue,
                  ), // Set label text color to blue
                ),
                value: selectedPaymentMode,
                items: ['Cash', 'Credit', 'Bank']
                    .map(
                      (mode) =>
                          DropdownMenuItem(value: mode, child: Text(mode)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedPaymentMode = val!),
              ),
              SizedBox(height: 10),
              if (selectedPaymentMode == 'Credit')
                TextFormField(
                  controller: paidAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Paid Amount',
                    labelStyle: TextStyle(
                      color: Colors.blue,
                    ), // Set label text color to blue
                  ),
                  validator: (val) {
                    if (selectedPaymentMode == 'Credit') {
                      final parsed = double.tryParse(val ?? '');
                      if (parsed == null || parsed < 0) {
                        return 'Enter valid paid amount';
                      }
                    }
                    return null;
                  },
                ),
              SizedBox(height: 10),
              Text(
                "Total: ₹${totalAmount.toStringAsFixed(2)} + Tax: ₹${totalTax.toStringAsFixed(2)} = ₹${(totalAmount + totalTax).toStringAsFixed(2)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(height: 30),
              Text(
                "Sales Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(height: 10),
              Form(
                key: _itemFormKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Add padding around the form
                    child: Column(
                      children: [
                        // Item Dropdown
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 12,
                          ), // Add bottom margin to separate fields
                          child: CustomTextFieldSearchable(
                            label: 'Item Name',
                            searchCallback: (query) async {
                              return items
                                  .where(
                                    (item) => (item['name'] ?? '')
                                        .toLowerCase()
                                        .contains(query.toLowerCase()),
                                  )
                                  .toList();
                            },
                            onItemSelected: (item) async {
                              setState(() {
                                selectedItem = item;
                                selectedItemId = item['id'];
                              });
                              try {
                                final itemDetails =
                                    await _itemsCollectionService
                                        .getItemByItemId(
                                          selectedItemId.toString(),
                                        );

                                if (itemDetails != null) {
                                  final rateRaw = itemDetails['rate'];
                                  final taxRaw = itemDetails['tax'];

                                  final double rate = rateRaw is String
                                      ? double.tryParse(rateRaw) ?? 0.0
                                      : (rateRaw as num?)?.toDouble() ?? 0.0;

                                  final double tax = taxRaw is String
                                      ? double.tryParse(taxRaw) ?? 0.0
                                      : (taxRaw as num?)?.toDouble() ?? 0.0;
                                  final stockRaw = item['stock'];
                                  final double quantityStock =
                                      stockRaw is String
                                      ? double.tryParse(stockRaw) ?? 0.0
                                      : (stockRaw as num?)?.toDouble() ?? 0.0;
                                  setState(() {
                                    priceController.text = rate.toStringAsFixed(
                                      2,
                                    );
                                    taxPercentageController.text = tax
                                        .toStringAsFixed(2);
                                    stockController.text = quantityStock
                                        .toStringAsFixed(2);
                                  });
                                } else {
                                  debugPrint(
                                    "Item with itemId $selectedItemId not found.",
                                  );
                                }
                              } catch (e) {
                                debugPrint(
                                  "Error fetching item rate and tax: $e",
                                );
                              }
                            },
                            onManualEntry: (input) async {
                              setState(() {
                                selectedItem = {'name': input};
                              });
                              return {'name': input};
                            },
                          ),
                        ),

                        // Quantity TextField
                        Container(
                          margin: EdgeInsets.only(
                            bottom: 12,
                          ), // Margin between fields
                          child: TextFormField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Qty',
                              labelStyle: TextStyle(color: Colors.blue),
                            ),
                            validator: (val) {
                              final parsed = double.tryParse(val ?? '');
                              if (parsed == null || parsed <= 0) {
                                return 'Enter qty';
                              }
                              return null;
                            },
                          ),
                        ),

                        // Price and Tax TextFields
                        Row(
                          children: [
                            // Price TextField
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: 8,
                                ), // Spacing between fields
                                child: TextFormField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Price',
                                    labelStyle: TextStyle(color: Colors.blue),
                                  ),
                                  validator: (val) {
                                    final parsed = double.tryParse(val ?? '');
                                    if (parsed == null || parsed < 0) {
                                      return 'Enter price';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: 8,
                                ), // Spacing between fields
                                child: TextFormField(
                                  controller: stockController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Stock',
                                    labelStyle: TextStyle(color: Colors.blue),
                                    enabled: false,
                                  ),
                                ),
                              ),
                            ),

                            // Tax TextField
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 8,
                                ), // Spacing between fields
                                child: TextFormField(
                                  controller: taxPercentageController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Tax (%)',
                                    labelStyle: TextStyle(color: Colors.blue),
                                  ),
                                  validator: (val) {
                                    final parsed = double.tryParse(val ?? '');
                                    if (parsed == null || parsed < 0) {
                                      return 'Enter tax';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 16,
                        ), // Space between the form fields and the button
                        // Add Item Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: addItemToSale,
                            ),
                            SizedBox(
                              width: 8,
                            ), // Add space between icon and text
                            Text(
                              'Add Item',
                              style: TextStyle(
                                color:
                                    Colors.blue, // Set the text color to blue
                                fontSize: 16, // Adjust the font size as needed
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: saleItems.length,
                itemBuilder: (context, index) {
                  final item = saleItems[index];
                  return ListTile(
                    title: Text(item['itemName']),
                    subtitle: Text(
                      "Qty: ${item['quantity']} - ₹${item['price']} + Tax: ₹${item['taxAmount']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // TODO: Implement your edit logic here
                            _editItem(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteItem(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(onPressed: saveSale, child: Text("Save Sale")),
            ],
          ),
        ),
      ),
    );
  }
}
