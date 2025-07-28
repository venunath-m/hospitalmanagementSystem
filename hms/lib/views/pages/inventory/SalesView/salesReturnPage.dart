import 'package:flutter/material.dart';
import 'package:posapplication/customWidgets/chatarea/admin_chat_list_page.dart';
import 'package:posapplication/customWidgets/chatarea/admin_chat_orders_page.dart';
import 'package:posapplication/customWidgets/chatarea/chat_order_page.dart';
import 'package:posapplication/customWidgets/customSearchTextField/customSearchTextField.dart';
import 'package:posapplication/customWidgets/customSearchTextField/customTextFieldSearchable.dart';
import 'package:posapplication/customWidgets/messagespopUp/customMessage.dart';
import 'package:posapplication/fireStore_service/accountBookCollection_service.dart';
import 'package:posapplication/fireStore_service/customerLedger_service.dart';
import 'package:posapplication/fireStore_service/customer_service.dart';
import 'package:posapplication/fireStore_service/itemsCollection_service.dart';
import 'package:posapplication/fireStore_service/sales_return_details_service.dart';
import 'package:posapplication/fireStore_service/salesreturndetailcollection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesReturnPage extends StatefulWidget {
  @override
  _SalesReturnPageState createState() => _SalesReturnPageState();
}

class _SalesReturnPageState extends State<SalesReturnPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemFormKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> returnItems = [];
  double totalReturnAmount = 0;
  double totalReturnTax = 0;
  String? userId;
  String? selectedItemId;
  Map<String, dynamic>? selectedCustomer;
  Map<String, dynamic>? selectedItem;
  List<Map<String, dynamic>> items = [];
  // Use similar controllers or models from your sales page
  // Example controllers:
  final quantityController = TextEditingController();
  final reasonController = TextEditingController();
  final priceController = TextEditingController();
  final taxPercentageController = TextEditingController();
  // ... include other controllers like item, price, tax etc.
  final CustomerService _customerService = CustomerService();
  final SalesReturnCollectionService _salesReturnCollectionService =
      SalesReturnCollectionService();
  final SalesReturnDetailCollectionService _salesReturnDetailCollectionService =
      SalesReturnDetailCollectionService();
  final ItemsCollectionService _itemsCollectionService =
      ItemsCollectionService();
  final AccountBookCollectionService _accountBookCollectionService =
      AccountBookCollectionService();
  final CustomerledgerService _customerledgerService = CustomerledgerService();
  void navigateToChatOrderPage({required BuildContext context}) {
    var userId = getUserIdFromPrefs().toString();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatOrderPage(chatId: userId, userId: userId),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    final prefs = await SharedPreferences.getInstance(); // ✅ Define prefs here
    userId = prefs.getString('userId');
    final customerRecords = await _customerService.getAllCustomers();
    final itemRecords = await _itemsCollectionService.getAllItems();

    setState(() {
      customers =
          customerRecords.map((e) {
            return {
              'id': e['id'], // Use the Firestore document ID instead of 'key'
              ...e, // Include the rest of the data
            };
          }).toList();

      items =
          itemRecords.map((e) {
            return {
              'id': e['id'], // Use the Firestore document ID instead of 'key'
              ...e, // Include the rest of the data
            };
          }).toList();
    });
  }

  void navigateToAdminChatOrderPage({required BuildContext context}) {
    var userId = getUserIdFromPrefs().toString();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminChatOrdersPage()),
    );
  }

  void addItemToReturn() {
    if (_itemFormKey.currentState!.validate()) {
      final qty = double.parse(quantityController.text);
      final price = double.parse(priceController.text);
      final taxPct = double.parse(taxPercentageController.text);

      final taxAmount = qty * price * (taxPct / 100);
      final itemTotal = qty * price + taxAmount;

      setState(() {
        returnItems.add({
          'id': selectedItem!['id'], // ✅ Add this
          'itemName': selectedItem!['name'],
          'quantity': qty,
          'price': price,
          'taxPercentage': taxPct,
          'taxAmount': taxAmount,
          'itemTotalAmount': itemTotal,
          'reason': reasonController.text,
        });

        totalReturnAmount += qty * price;
        totalReturnTax += taxAmount;
      });

      // Clear input fields after adding
      quantityController.clear();
      priceController.clear();
      taxPercentageController.clear();
      reasonController.clear();
    }
  }

  Future<String?> getUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> saveSalesReturn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (_formKey.currentState?.validate() != true ||
          selectedCustomer == null ||
          returnItems.isEmpty) {
        if (mounted) {
          await CustomMessageDialog.show(
            context,
            title: 'Validation Error',
            message: 'Please complete all required fields before saving.',
            buttonText: 'OK',
          );
        }
        return;
      }

      var existingCustomer = await _customerService.getCustomerByNameAndAddress(
        selectedCustomer?['name'] ?? '',
        selectedCustomer?['billingAddress'] ?? '',
      );

      String customerId;
      final customerDataEntries = {
        'name': selectedCustomer?['name'] ?? '',
        'billingAddress': selectedCustomer?['billingAddress'] ?? '',
        'shippingAddress': selectedCustomer?['shippingAddress'] ?? '',
        'contact': null,
        'gstin': null,
        'balance': 0.0,
      };

      if (existingCustomer == null) {
        customerId = await _customerService.addCustomer(customerDataEntries);
      } else {
        customerId = existingCustomer['id'];
      }

      double totalReturn = totalReturnAmount;
      double taxReturn = totalReturnTax;
      double grandTotal = totalReturn + taxReturn;

      // 1. Save sales return summary
      final returnId = await _salesReturnCollectionService
          .addSalesReturnSummary({
            'customerId': customerId,
            'customerName': selectedCustomer?['name'] ?? '',
            'returnDate': DateTime.now().toIso8601String(),
            'returnAmount': totalReturn,
            'taxAmount': taxReturn,
            'grandTotal': grandTotal,
          });

      // 2. Save individual return items
      for (var item in returnItems) {
        if (item['id'] == null) {
          print("ERROR: item['id'] is null");
          continue;
        }

        await _salesReturnDetailCollectionService.addSalesReturnDetail({
          'salesReturnId': returnId,
          ...item,
          'total': item['itemTotalAmount'],
        });

        await _itemsCollectionService.increaseItemStock(
          item['id'],
          item['quantity'],
        );
      }

      // 4. Add accounting record (refund or balance adjustment)
      await _accountBookCollectionService.addAccountBookEntry({
        'transactionType': 'SalesReturn',
        'credit': grandTotal, // company pays back / customer gets credit
        'debit': 0.0,
        'description': 'Sales Return by ${selectedCustomer!['name']}',
        'accountId': 1,
        'date': DateTime.now().toIso8601String(),
        'paymentMode': 'Return',
      });

      // 5. Adjust customer balance ledger
      await _customerledgerService.addCustomerLedgerEntry(
        entry: {
          'customerId': customerId,
          'name': selectedCustomer?['name'],
          'date': DateTime.now().toIso8601String(),
          'description': 'Sales Return - Return ID $returnId',
          'credit': grandTotal,
          'type': 'Credit',
        },
      );

      await _customerService.updateCustomerBalance(customerId, -grandTotal);

      if (!mounted) return;

      await CustomMessageDialog.show(
        context,
        title: 'Success',
        message: "Sales Return saved successfully!",
        buttonText: 'OK',
      );

      // Reset form state
      setState(() {
        selectedCustomer = null;
        returnItems.clear();
        totalReturnAmount = 0;
        totalReturnTax = 0;
        quantityController.clear();
        priceController.clear();
        taxPercentageController.clear();
        reasonController.clear();
      });
    } catch (e, stacktrace) {
      print('❌ Sales Return save failed: $e');
      print(stacktrace);
      if (mounted) {
        await CustomMessageDialog.show(
          context,
          title: 'Error',
          message: 'Failed to save sales return. Please try again.\nError: $e',
          buttonText: 'OK',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Return'),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.indigo),
        titleTextStyle: const TextStyle(
          color: Colors.indigo,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFieldSearchable(
                label: 'Enter Customer',
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
                    selectedCustomer = item; // Update selected customer
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
              const SizedBox(height: 10),
              Form(
                key: _itemFormKey,
                child: Column(
                  children: [
                    CustomTextFieldSearchable(
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
                          final itemDetails = await _itemsCollectionService
                              .getItemByItemId(selectedItemId.toString());

                          if (itemDetails != null) {
                            final double rate =
                                (itemDetails['rate'] as num?)?.toDouble() ??
                                0.0;
                            final double tax =
                                (itemDetails['tax'] as num?)?.toDouble() ?? 0.0;
                            final double quantityStock =
                                (item['stock'] as num?)?.toDouble() ?? 0.0;

                            setState(() {
                              priceController.text = rate.toStringAsFixed(2);
                              taxPercentageController.text = tax
                                  .toStringAsFixed(2);
                            });
                          } else {
                            debugPrint(
                              "Item with itemId $selectedItemId not found.",
                            );
                          }
                        } catch (e) {
                          debugPrint("Error fetching item rate and tax: $e");
                        }
                      },
                      onManualEntry: (input) async {
                        setState(() {
                          selectedItem = {'name': input};
                        });
                        return {'name': input};
                      },
                    ),
                    TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Return Quantity',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final qty = double.tryParse(val ?? '');
                        if (qty == null || qty <= 0)
                          return 'Enter valid quantity';
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator:
                          (val) =>
                              double.tryParse(val ?? '') == null
                                  ? 'Enter valid price'
                                  : null,
                    ),
                    TextFormField(
                      controller: taxPercentageController,
                      decoration: const InputDecoration(labelText: 'Tax (%)'),
                      keyboardType: TextInputType.number,
                      validator:
                          (val) =>
                              double.tryParse(val ?? '') == null
                                  ? 'Enter valid tax'
                                  : null,
                    ),
                    TextFormField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Return',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: addItemToReturn,
                      icon: const Icon(Icons.add),
                      label: const Text("Return Item"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 30),
              Text(
                "Returned Items",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: returnItems.length,
                itemBuilder: (context, index) {
                  final item = returnItems[index];
                  return ListTile(
                    title: Text(item['itemName']),
                    subtitle: Text(
                      "Qty: ${item['quantity']} | Reason: ${item['reason']}",
                    ),
                    trailing: Text(
                      "₹${item['itemTotalAmount'].toStringAsFixed(2)}",
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Total Return: ₹${totalReturnAmount.toStringAsFixed(2)} + Tax: ₹${totalReturnTax.toStringAsFixed(2)} = ₹${(totalReturnAmount + totalReturnTax).toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveSalesReturn,
                child: const Text("Save Sales Return"),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     navigateToChatOrderPage(context: context);
              //   },
              //   child: const Text("chat"),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     navigateToAdminChatOrderPage(context: context);
              //   },
              //   child: const Text("chatAdmin"),
              // ),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => const AdminChatListPage(),
              //       ),
              //     );
              //   },
              //   child: const Text("Open Chat Panel"),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
