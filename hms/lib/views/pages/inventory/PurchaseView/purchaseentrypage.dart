import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/custom_component_widgets/shared_widgets/PopupMessage_Widget.dart';
import 'package:intl/intl.dart'; // for date formatting
import 'package:hms/fireStore_service/accountBookCollection_service.dart';
import 'package:hms/fireStore_service/itemsCollection_service.dart';
import 'package:hms/fireStore_service/purchaseDetail_service.dart';
import 'package:hms/fireStore_service/purchaseSummaryCollection_service.dart';
import 'package:hms/fireStore_service/supplierCollection_service.dart';
import 'package:hms/fireStore_service/supplierLedgerCollection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseEntryPage extends StatefulWidget {
  @override
  _PurchaseEntryPageState createState() => _PurchaseEntryPageState();
}

class _PurchaseEntryPageState extends State<PurchaseEntryPage> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> suppliers = [];
  late String selectedItemId;
  String? userId;
  Map<String, dynamic>? selectedSupplier;
  String selectedPayMode = 'Cash';

  final TextEditingController invoiceNumberController = TextEditingController();
  final TextEditingController mrpController = TextEditingController();
  final TextEditingController itemCostController = TextEditingController();
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController acceptDateController = TextEditingController();
  final ItemsCollectionService _itemsCollectionService =
      ItemsCollectionService();
  final SuppliercollectionService _suppliercollectionService =
      SuppliercollectionService();
  final PurchaseSummaryCollectionService _purchaseSummaryCollectionService =
      PurchaseSummaryCollectionService();
  final PurchasedetailService _purchasedetailService = PurchasedetailService();
  final AccountBookCollectionService _accountBookCollectionService =
      AccountBookCollectionService();
  final SupplierledgercollectionService _supplierledgercollectionService =
      SupplierledgercollectionService();
  Map<String, dynamic>? selectedItem;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController taxPercentageitemController =
      TextEditingController();
  final TextEditingController taxAmountItemController = TextEditingController();
  final TextEditingController freightController = TextEditingController();
  final TextEditingController otherExpenseController = TextEditingController();
  // New controller for tax percentage
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  List<Map<String, dynamic>> itemRows = [];

  // Calculate total amount based on user-defined tax percentage
  double get totalAmount {
    double taxPercentage =
        double.tryParse(taxPercentageitemController.text) ?? 10.0;
    return itemRows.fold(0.0, (sum, item) {
      final rowTotal = item['quantity'] * item['unitPrice'];
      final rowTax =
          rowTotal *
          (item['taxPercentage'] /
              100); // Tax is now calculated for each item individually
      return sum + rowTotal + rowTax;
    });
  }

  // Calculate tax amount for the entire purchase
  double get totalTax {
    return itemRows.fold(0.0, (sum, item) {
      final rowTotal = item['quantity'] * item['unitPrice'];
      final rowTax = rowTotal * (item['taxPercentage'] / 100); // Tax per item
      return sum + rowTax;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadSuppliers();
  }

  Future<void> _loadItems() async {
    final records = await _itemsCollectionService.getAllItems();
    setState(() {
      items = records; // No mapping needed
    });
  }

  Future<void> _loadSuppliers() async {
    final records = await _suppliercollectionService.getAllSuppliers();
    setState(() {
      suppliers = records; // No mapping needed
    });
  }

  void _addItemRow() async {
    final quantity = double.tryParse(quantityController.text) ?? 0.0;
    final unitPrice = double.tryParse(priceController.text) ?? 0.0;
    final itemCost = double.tryParse(itemCostController.text) ?? 0.0;
    final mrp = double.tryParse(mrpController.text) ?? 0.0;
    final taxPercentage =
        double.tryParse(taxPercentageitemController.text) ?? 10.0;

    if (selectedItem == null || quantity <= 0 || unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill item, quantity, and unit price')),
      );
      return;
    }
    var existingItem = await _itemsCollectionService.getItemByName(
      selectedItem?['name'] ?? '',
    );

    int itemId;
    if (existingItem == null) {
      selectedItemId = await _itemsCollectionService.addItem({
        'name': selectedItem?['name'] ?? '',
        'unit': '',
        'rate': unitPrice,
        'tax': taxPercentage,
        'cgst': 0,
        'sgst': 0,
        'igst': 0,
        'hsnCode': 0,
        'subCategory': '',
        'itemCost': 0,
        'mrp': 0,
        'stock': 0,
      });
    } else {
      itemId = existingItem['id'];
    }
    setState(() {
      itemRows.add({
        'itemID': selectedItemId,
        'itemName': selectedItem!['name'],
        'quantity': quantity,
        'unitPrice': unitPrice,
        'taxPercentage': taxPercentage, // Individual tax percentage per item
        'taxAmount': (quantity * unitPrice) * (taxPercentage / 100),
        'itemCost': itemCost,
        'mrp': mrp, // Calculate individual tax amount
      });
      selectedItem = null;
      quantityController.clear();
      priceController.clear();
      taxPercentageitemController.clear();
    });
  }

  void _removeItemRow(int index) {
    setState(() {
      itemRows.removeAt(index);
    });
  }

  void calculateItemCosts() {
    double landingCost = double.tryParse(freightController.text) ?? 0;
    double otherExpenses = double.tryParse(otherExpenseController.text) ?? 0;
    double totalExtraCost = landingCost + otherExpenses;

    int totalQuantity = itemRows.fold<int>(0, (sum, item) {
      return sum + (item['quantity'] as int);
    });

    if (totalQuantity == 0) return;

    double extraCostPerUnit = totalExtraCost / totalQuantity;

    for (var item in itemRows) {
      double unitPrice = item['unitPrice'];
      int quantity = item['quantity'];
      double taxPercentage = item['taxPercentage'] ?? 0;

      // Tax on unit price
      double taxAmount = (unitPrice * taxPercentage) / 100;

      // Final item cost = base price + tax + extra distributed cost
      double itemCost = unitPrice + taxAmount + extraCostPerUnit;

      item['itemCost'] = itemCost;

      // Optionally update the controller (this will always show the last item's cost)
      itemCostController.text = itemCost.toStringAsFixed(2);
    }

    setState(() {});
  }

  Future<void> _savePurchase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      final freightCharges = double.tryParse(freightController.text) ?? 0.0;
      final otherCharges = double.tryParse(otherExpenseController.text) ?? 0.0;

      if (!_formKey.currentState!.validate() ||
          selectedSupplier == null ||
          itemRows.isEmpty) {
        if (mounted) {
          await PopupMessage.show(
            context,
            title: 'Validation Error',
            message: 'Please complete all fields and add at least one item',
            icon: Icons.error_outline,
            iconColor: Colors.red,
            actionButtons: [
              PopupActionButton(
                label: 'OK',
                icon: Icons.check,
                onPressed: () {
                  // No extra logic needed — popup will close automatically
                },
              ),
            ],
            autoDismiss: false, // So user can read and close manually
          );
        }
        return;
      }

      var supplierId = selectedSupplier!['id'];
      final supplierName = selectedSupplier!['name'];
      final invoiceNo = invoiceNumberController.text;
      final invoiceDate = invoiceDateController.text;
      final acceptedDate = acceptDateController.text;

      var existingSupplier = await _suppliercollectionService.getSupplierByName(
        selectedSupplier?['name'] ?? '',
      );

      if (existingSupplier == null) {
        supplierId = await _suppliercollectionService.addSupplier({
          'name': selectedSupplier!['name'],
          'address': null,
          'phone': null,
          'email': null,
        });
      } else {
        supplierId = existingSupplier['id'];
      }

      final taxableAmount = itemRows.fold(
        0.0,
        (sum, item) => sum + (item['quantity'] * item['unitPrice']),
      );
      final totalTax = itemRows.fold(
        0.0,
        (sum, item) => sum + item['taxAmount'],
      );
      final invoiceAmount = taxableAmount + totalTax;

      final purchaseSummary = {
        'supplierId': supplierId,
        'supplierName': supplierName,
        'InvoiceNo': invoiceNo,
        'invoiceDate': invoiceDate,
        'AcceptedDate': acceptedDate,
        'discountAmount': 0.0,
        'invoiceAmount': invoiceAmount,
        'taxAmount': totalTax,
        'purchaseAmount': taxableAmount,
        'purchaseIsClosed': 0,
        'purchasePayMode': selectedPayMode,
        'balanceAmount': invoiceAmount,
        'paidDate': acceptedDate,
        'freightCharges': freightCharges,
        'otherCharges': otherCharges,
        'purchaseEnteredBy': 'admin',
        'purchaseEnteredDate': DateTime.now().toIso8601String().split('T')[0],
        'purchaseEnteredTime': TimeOfDay.now().format(context),
        'company_id': 1,
        'outlet_id': 1,
      };

      final purchaseId = await _purchaseSummaryCollectionService
          .addPurchaseSummary(purchaseSummary);

      for (final row in itemRows) {
        final itemId = row['itemID'];
        final itemName = row['itemName'];
        final qty = row['quantity'];
        final price = row['unitPrice'];
        final itemCost = row['itemCost'];
        final mrp = row['mrp'];
        final rowTotal = qty * price;
        final rowTax = row['taxAmount'];

        final detail = {
          'purchaseID': purchaseId,
          'itemID': itemId,
          'itemName': itemName,
          'quantity': qty,
          'unitPrice': price,
          'itemCost': itemCost,
          'mrp': mrp,
          'totalAmount': rowTotal,
          'cgst': rowTax / 2,
          'sgst': rowTax / 2,
          'igst': 0.0,
          'taxAmount': rowTax,
          'taxableAmount': rowTotal,
          'company_id': 1,
          'outlet_id': 1,
        };

        await _purchasedetailService.addPurchaseDetail(detail);
        await _itemsCollectionService.updateItemStockPurchase(itemId, qty);
      }

      final paidAmount = invoiceAmount;
      final selectedDate = DateTime.now();
      final transactionType = selectedPayMode == 'Cash' ? 'Credit' : 'Debit';
      final transactionAmount = selectedPayMode == 'Cash' ? paidAmount : 0.0;
      final companyId = prefs.getString('companyId') ?? '';

      /// 1. Ensure "Purchase" group exists
      final purchaseGroupSnapshot = await FirebaseFirestore.instance
          .collection('account_groups')
          .where('headName', isEqualTo: 'Purchase Group A/C')
          .where('companyId', isEqualTo: companyId)
          .limit(1)
          .get();

      String purchaseGroupId;
      if (purchaseGroupSnapshot.docs.isNotEmpty) {
        purchaseGroupId = purchaseGroupSnapshot.docs.first.id;
      } else {
        final newGroup = await FirebaseFirestore.instance
            .collection('account_groups')
            .add({
              'headName': 'Purchase Group A/C',
              'description': 'Purchase Group',
              'accountType': 'Expense',
              'companyId': companyId,
              'userId': userId,
            });
        purchaseGroupId = newGroup.id;
      }

      /// 2. Ensure "Purchase A/C" account head exists
      final purchaseHeadSnapshot = await FirebaseFirestore.instance
          .collection('account_heads')
          .where('headName', isEqualTo: 'Purchase A/C')
          .where('companyId', isEqualTo: companyId)
          .limit(1)
          .get();

      String purchaseAccountHeadId;
      if (purchaseHeadSnapshot.docs.isNotEmpty) {
        purchaseAccountHeadId = purchaseHeadSnapshot.docs.first.id;
      } else {
        final newHead = await FirebaseFirestore.instance
            .collection('account_heads')
            .add({
              'headName': 'Purchase A/C',
              'description': 'Purchase A/C',
              'selectedGroup': purchaseGroupId,
              'companyId': companyId,
              'userId': userId,
            });
        purchaseAccountHeadId = newHead.id;
      }

      final accountBookEntry = {
        'transactionType': transactionType,
        'debit': transactionAmount,
        'credit': selectedPayMode == 'Credit' ? paidAmount : 0.0,
        'description': 'Purchase from $supplierName ($selectedPayMode)',
        'accountId': purchaseAccountHeadId,
        'date': selectedDate.toIso8601String(),
        'paymentMode': selectedPayMode,
      };

      await _accountBookCollectionService.addAccountBookEntry(accountBookEntry);

      double balanceAmount = invoiceAmount;
      if (balanceAmount > 0) {
        final ledgerEntry = {
          'supplierId': supplierId,
          'name': supplierName,
          'date': selectedDate.toIso8601String(),
          'description': 'Credit Purchase Balance for Invoice :- $invoiceNo',
          'credit': balanceAmount,
          'type': 'Debit',
        };

        await _supplierledgercollectionService.addSupplierLedgerEntry(
          ledgerEntry,
        );
        await _suppliercollectionService.updateSupplierBalance(
          supplierId,
          balanceAmount,
        );
      }

      if (mounted) {
        await PopupMessage.show(
          context,
          title: 'Success',
          message: 'Purchase saved successfully!',
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          actionButtons: [
            PopupActionButton(
              label: 'OK',
              icon: Icons.check,
              onPressed: () {
                // Optional: Close or trigger any follow-up
              },
            ),
          ],
        );
      }
      _resetForm();
    } catch (e, stacktrace) {
      print('❌ Purchase save failed: $e');
      print(stacktrace);
      if (mounted) {
        await PopupMessage.show(
          context,
          title: 'Error',
          message: 'Failed to save purchase. Please try again.\nError: $e',
          icon: Icons.error_outline,
          iconColor: Colors.red,
          actionButtons: [
            PopupActionButton(label: 'OK', icon: Icons.close, onPressed: () {}),
          ],
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      selectedSupplier = null;
      selectedItem = null;
      itemRows.clear();
      selectedPayMode = 'Cash';
    });
    invoiceNumberController.clear();
    invoiceDateController.clear();
    acceptDateController.clear();
    quantityController.clear();
    priceController.clear();
    selectedItem = null;
    taxPercentageitemController.clear();
    freightController.clear();
    mrpController.clear();
    itemCostController.clear();
    mrpController.clear();
  }

  // Date picker function
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shopping_bag, color: Colors.indigo),
            SizedBox(width: 8),
            Text(
              'Purchase Entry',
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SearchableFlexibleInputField(
                                label: 'Enter Supplier',
                                controller: supplierController,
                                isRequired: true,
                                searchCallback: (query) async {
                                  return suppliers
                                      .where(
                                        (customer) => (customer['name'] ?? '')
                                            .toLowerCase()
                                            .contains(query.toLowerCase()),
                                      )
                                      .toList();
                                },
                                onItemSelected: (item) {
                                  setState(() {
                                    selectedSupplier = item;
                                  });
                                },
                                onManualEntry: (input) async {
                                  setState(() {
                                    selectedSupplier = {'name': input};
                                  });
                                  return {'name': input};
                                },
                              ),

                              TextFormField(
                                controller: invoiceNumberController,
                                decoration: InputDecoration(
                                  labelText: "Invoice Number",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              TextFormField(
                                controller: invoiceDateController,
                                decoration: InputDecoration(
                                  labelText: "Invoice Date (YYYY-MM-DD)",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                readOnly: true,
                                onTap: () =>
                                    _selectDate(context, invoiceDateController),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              TextFormField(
                                controller: acceptDateController,
                                decoration: InputDecoration(
                                  labelText: "Accepted Date (YYYY-MM-DD)",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                readOnly: true,
                                onTap: () =>
                                    _selectDate(context, acceptDateController),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              TextFormField(
                                controller: freightController,
                                decoration: InputDecoration(
                                  labelText: "Landing Cost",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              TextFormField(
                                controller: otherExpenseController,
                                decoration: InputDecoration(
                                  labelText: "Other Expenses",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              SizedBox(height: 16),
                              Text('Items'),
                              SearchableFlexibleInputField(
                                label: 'Item Name',
                                controller:
                                    itemNameController, // a TextEditingController you define
                                isRequired: true,
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
                                      final double rate =
                                          (itemDetails['rate'] as num?)
                                              ?.toDouble() ??
                                          0.0;
                                      final double mrp =
                                          (itemDetails['mrp'] as num?)
                                              ?.toDouble() ??
                                          0.0;
                                      final double tax =
                                          (itemDetails['tax'] as num?)
                                              ?.toDouble() ??
                                          0.0;

                                      setState(() {
                                        priceController.text = rate
                                            .toStringAsFixed(2);
                                        taxPercentageitemController.text = tax
                                            .toStringAsFixed(2);
                                        mrpController.text = mrp
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

                              TextFormField(
                                controller: quantityController,
                                decoration: InputDecoration(
                                  labelText: "Quantity",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                keyboardType: TextInputType.number,
                              ),
                              TextFormField(
                                controller: priceController,
                                decoration: InputDecoration(
                                  labelText: "Unit Price",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                keyboardType: TextInputType.number,
                              ),
                              TextFormField(
                                controller: taxPercentageitemController,
                                decoration: InputDecoration(
                                  labelText: "Tax %",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                keyboardType: TextInputType.number,
                              ),
                              TextFormField(
                                controller: mrpController,
                                decoration: InputDecoration(
                                  labelText: "Mrp",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                keyboardType: TextInputType.number,
                              ),
                              TextFormField(
                                controller: itemCostController,
                                decoration: InputDecoration(
                                  labelText: "Item Cost",
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                  ), // Blue label
                                ),
                                style: TextStyle(
                                  color: Colors.blue,
                                ), // Blue text
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _addItemRow,
                                child: Text('Add Item'),
                              ),
                              SizedBox(height: 16),
                              Text('Items Added:'),
                              if (itemRows.isNotEmpty)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 1000),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: [
                                          DataColumn(label: Text('Item')),
                                          DataColumn(label: Text('Quantity')),
                                          DataColumn(label: Text('Unit Price')),
                                          DataColumn(label: Text('Tax %')),
                                          DataColumn(label: Text('Action')),
                                        ],
                                        rows: itemRows.map((item) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(item['itemName'])),
                                              DataCell(
                                                Text(
                                                  item['quantity'].toString(),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  item['unitPrice'].toString(),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  item['taxPercentage']
                                                      .toString(),
                                                ),
                                              ),
                                              DataCell(
                                                IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () =>
                                                      _removeItemRow(
                                                        itemRows.indexOf(item),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 16),
                              Text(
                                'Total Amount:  ${totalAmount.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Tax Amount:  ${totalTax.toStringAsFixed(2)}',
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: Column(
                                  children: [
                                    DropdownButton<String>(
                                      value: selectedPayMode,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedPayMode = newValue!;
                                        });
                                      },
                                      items: ['Cash', 'Credit']
                                          .map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          })
                                          .toList(),
                                      hint: Text('Transaction Type'),
                                      style: TextStyle(color: Colors.blue),
                                      dropdownColor: Colors.white,
                                    ),

                                    const SizedBox(width: 24),
                                    ElevatedButton(
                                      onPressed: _savePurchase,
                                      child: Text('Save'),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
