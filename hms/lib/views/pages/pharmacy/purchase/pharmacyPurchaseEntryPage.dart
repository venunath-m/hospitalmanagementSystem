import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets/SearchableFlexibleInputField.dart';
import 'package:intl/intl.dart';
import '../models/purchase_item_model.dart';
import '../widgets/purchase_item_form_dialog.dart';

class PharmacyPurchaseEntryPage extends StatefulWidget {
  const PharmacyPurchaseEntryPage({Key? key}) : super(key: key);

  @override
  State<PharmacyPurchaseEntryPage> createState() =>
      _PharmacyPurchaseEntryPageState();
}

class _PharmacyPurchaseEntryPageState extends State<PharmacyPurchaseEntryPage> {
  List<PurchaseItemModel> purchaseItems = [];
  DateTime invoiceDate = DateTime.now();
  DateTime accountingDate = DateTime.now();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController invoiceController = TextEditingController();
  bool isClosed = false;
  Map<String, dynamic>? selectedSupplier;
  Map<String, dynamic>? selectedInvoice;
  Map<String, dynamic>? purchaseDetails; // fetched invoice details
  bool isInterState = false; // Toggle between intra/inter state tax
  double discount = 0;
  double roundOff = 0;

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  // Invoice file path placeholder
  String? invoiceFileName;
  Future<bool?> _showCloseConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Purchase'),
        content: const Text('Do you want to close this purchase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> searchSuppliers(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    final suppliers = [
      {'id': 1, 'name': 'Supplier A'},
      {'id': 2, 'name': 'Supplier B'},
    ];

    return suppliers.where((supplier) {
      final name = supplier['name'];
      if (name is String) {
        return name.toLowerCase().contains(query.toLowerCase());
      }
      return false;
    }).toList();
  }

  // Simulate searching invoices from DB or API
  Future<List<Map<String, dynamic>>> searchInvoices(String query) async {
    await Future.delayed(Duration(milliseconds: 300));
    final invoices = [
      {'id': 101, 'name': 'INV001', 'isClosed': false},
      {'id': 102, 'name': 'INV002', 'isClosed': true},
    ];

    return invoices.where((invoice) {
      final name = invoice['name'];
      if (name is String) {
        return name.toLowerCase().contains(query.toLowerCase());
      }
      return false;
    }).toList();
  }

  // Simulate manual entry for supplier
  Future<Map<String, dynamic>> manualSupplierEntry(String input) async {
    // You might create a new supplier here or return an object
    return {'id': 999, 'name': input};
  }

  // Simulate manual entry for invoice
  Future<Map<String, dynamic>> manualInvoiceEntry(String input) async {
    // New invoice
    return {'id': 9999, 'name': input, 'isClosed': false};
  }

  // Fetch purchase details for selected invoice if not closed
  Future<void> loadInvoiceDetails(Map<String, dynamic> invoice) async {
    if (invoice['isClosed'] == false) {
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        purchaseDetails = {
          'supplierId': 1,
          'supplierName': 'Supplier A',
          'invoiceId': invoice['id'],
          'invoiceNumber': invoice['name'],
          'items': [
            {
              'medicineName': 'Product X',
              'hsnCode': '1234',
              'quantity': 10.0,
              'rate': 100.0,
              'saleRate': 120.0,
              'batchNo': 'B123',
              'expiryDate': DateTime.now(),
              'taxPercent': 12.0,
              'taxInclusive': false,
            },
            // more items...
          ],
        };

        supplierController.text = purchaseDetails!['supplierName'];
        invoiceController.text = purchaseDetails!['invoiceNumber'];
        selectedSupplier = {
          'id': purchaseDetails!['supplierId'],
          'name': purchaseDetails!['supplierName'],
        };
        selectedInvoice = invoice;

        // Convert map items to PurchaseItemModel list
        purchaseItems = (purchaseDetails!['items'] as List<dynamic>)
            .map(
              (itemMap) => PurchaseItemModel(
                medicineName: itemMap['medicineName'],
                hsnCode: itemMap['hsnCode'],
                quantity: itemMap['quantity'],
                rate: itemMap['rate'],
                saleRate: itemMap['saleRate'],
                batchNo: itemMap['batchNo'],
                expiryDate: itemMap['expiryDate'],
                taxPercent: itemMap['taxPercent'],
                taxInclusive: itemMap['taxInclusive'],
              ),
            )
            .toList();
      });
    } else {
      setState(() {
        purchaseDetails = null;
        selectedInvoice = invoice;
        purchaseItems = [];
      });
    }
  }

  void onSupplierSelected(Map<String, dynamic> supplier) {
    setState(() {
      selectedSupplier = supplier;
    });
  }

  Future<void> _onSavePressed() async {
    if (purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one purchase item!')),
      );
      return;
    }

    final bool? closeConfirmed = await _showCloseConfirmDialog();
    if (closeConfirmed == null) return; // user dismissed dialog

    setState(() {
      isClosed = closeConfirmed;
    });

    // Now save your purchase, include isClosed value
    // TODO: implement actual save logic here

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          closeConfirmed
              ? 'Purchase saved and closed!'
              : 'Purchase saved but not closed!',
        ),
      ),
    );

    // Optionally pop back or reset form after save
  }

  void onInvoiceSelected(Map<String, dynamic> invoice) async {
    setState(() {
      selectedInvoice = invoice;
      purchaseDetails = null; // clear previous
    });
    await loadInvoiceDetails(invoice);
  }

  // Totals calculation
  double get totalQty =>
      purchaseItems.fold(0, (sum, item) => sum + item.quantity);

  double get subTotal => purchaseItems.fold(0, (sum, item) {
    final basePrice = item.taxInclusive
        ? item.rate / (1 + item.taxPercent / 100)
        : item.rate;
    return sum + (item.quantity * basePrice);
  });

  double get totalTax => purchaseItems.fold(0, (sum, item) {
    final basePrice = item.taxInclusive
        ? item.rate / (1 + item.taxPercent / 100)
        : item.rate;
    return sum + (item.quantity * basePrice * (item.taxPercent / 100));
  });

  // For simplicity, CGST and SGST are half of totalTax in intra state
  double get totalCgst => isInterState ? 0 : totalTax / 2;
  double get totalSgst => isInterState ? 0 : totalTax / 2;
  double get totalIgst => isInterState ? totalTax : 0;

  double get grandTotal => subTotal + totalTax - discount + roundOff;

  Future<void> _pickInvoiceFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(fileBytes);

      String normalize(String? value) =>
          value?.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') ?? '';

      final List<PurchaseItemModel> parsedItems = [];

      for (final sheet in excel.tables.keys) {
        final rows = excel.tables[sheet]!.rows;
        if (rows.length < 2) continue;

        final headers = rows.first
            .map((e) => normalize(e?.value.toString()))
            .toList();

        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];

          String? cell(String key) {
            final index = headers.indexWhere((h) => h.contains(key));
            return index != -1 && index < row.length
                ? row[index]?.value.toString()
                : null;
          }

          try {
            final item = PurchaseItemModel(
              medicineName: cell('medicine') ?? '',
              hsnCode: cell('hsn') ?? '',
              quantity: double.tryParse(cell('qty') ?? '') ?? 0,
              rate: double.tryParse(cell('rate') ?? '') ?? 0,
              saleRate: double.tryParse(cell('sale') ?? '') ?? 0,
              batchNo: cell('batch') ?? '',
              expiryDate:
                  DateTime.tryParse(cell('expiry') ?? '') ?? DateTime.now(),
              taxPercent: double.tryParse(cell('tax') ?? '') ?? 0,
              taxInclusive: false,
            );

            parsedItems.add(item);
          } catch (e) {
            debugPrint("⚠️ Failed to parse row $i: $e");
          }
        }
      }

      setState(() {
        invoiceFileName = result.files.single.name;
        purchaseItems.addAll(parsedItems);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Imported ${parsedItems.length} items from Excel'),
        ),
      );
    }
  }

  String normalizeHeader(String? header) =>
      header?.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') ?? '';

  Future<void> _addOrEditItem({PurchaseItemModel? existing, int? index}) async {
    final newItem = await showDialog<PurchaseItemModel>(
      context: context,
      builder: (_) => PurchaseItemFormDialog(initialItem: existing),
    );

    if (newItem != null) {
      setState(() {
        if (index != null) {
          purchaseItems[index] = newItem;
        } else {
          purchaseItems.add(newItem);
        }
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      purchaseItems.removeAt(index);
    });
  }

  @override
  void dispose() {
    supplierController.dispose();
    invoiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Purchase Entry'),
        backgroundColor: Colors.red.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Date pickers
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: invoiceDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setState(() => invoiceDate = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Invoice Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(dateFormat.format(invoiceDate)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Accounting Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(dateFormat.format(accountingDate)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: SearchableFlexibleInputField(
                      label: 'Supplier',
                      controller: supplierController,
                      searchCallback: searchSuppliers,
                      onItemSelected: onSupplierSelected,
                      onManualEntry: manualSupplierEntry,
                      isRequired: true,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: SearchableFlexibleInputField(
                      label: 'Invoice Number',
                      controller: invoiceController,
                      searchCallback: searchInvoices,
                      onItemSelected: onInvoiceSelected,
                      onManualEntry: manualInvoiceEntry,
                      isRequired: true,
                    ),
                  ),
                ),
              ],
            ),

            // Supplier State toggle for tax
            Row(
              children: [
                const Text('Inter State?'),
                Switch(
                  value: isInterState,
                  onChanged: (val) => setState(() => isInterState = val),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Items List
            Expanded(
              child: purchaseItems.isEmpty
                  ? const Center(child: Text('No purchase items added yet.'))
                  : ListView.builder(
                      itemCount: purchaseItems.length,
                      itemBuilder: (context, index) {
                        final item = purchaseItems[index];
                        final basePrice = item.taxInclusive
                            ? item.rate / (1 + item.taxPercent / 100)
                            : item.rate;
                        final subTotalItem = item.quantity * basePrice;
                        final taxAmountItem =
                            subTotalItem * (item.taxPercent / 100);
                        final totalItem = subTotalItem + taxAmountItem;

                        final marginPercent =
                            ((item.saleRate - item.rate) / item.rate) * 100;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(item.medicineName),
                            subtitle: Text(
                              'Qty: ${item.quantity}, Rate: ₹${item.rate.toStringAsFixed(2)}, Sale Rate: ₹${item.saleRate.toStringAsFixed(2)}\n'
                              'Batch: ${item.batchNo}, Expiry: ${dateFormat.format(item.expiryDate)}\n'
                              'Tax: ${item.taxPercent}%, Tax-Inclusive: ${item.taxInclusive}\n'
                              'Margin: ${marginPercent.toStringAsFixed(2)}%, Subtotal: ₹${subTotalItem.toStringAsFixed(2)}, Tax: ₹${taxAmountItem.toStringAsFixed(2)}, Total: ₹${totalItem.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _addOrEditItem(
                                    existing: item,
                                    index: index,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeItem(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 20),

            // Invoice Summary
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Total Quantity: $totalQty'),
                Text('Subtotal: ${currencyFormat.format(subTotal)}'),
                Text('CGST Total: ${currencyFormat.format(totalCgst)}'),
                Text('SGST Total: ${currencyFormat.format(totalSgst)}'),
                Text('IGST Total: ${currencyFormat.format(totalIgst)}'),
                Text('Total Tax: ${currencyFormat.format(totalTax)}'),
                Text('Grand Total: ${currencyFormat.format(grandTotal)}'),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Discount',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (val) {
                          final d = double.tryParse(val) ?? 0;
                          setState(() => discount = d);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Round-Off',
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (val) {
                          final r = double.tryParse(val) ?? 0;
                          setState(() => roundOff = r);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickInvoiceFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(invoiceFileName ?? 'Upload Invoice File'),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (purchaseItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add at least one purchase item!'),
                        ),
                      );
                      return;
                    }

                    final bool? closeConfirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Close Purchase'),
                        content: const Text(
                          'Do you want to close this purchase?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('No'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );

                    if (closeConfirmed == null) return; // user dismissed dialog

                    // TODO: Save to DB or API with isClosed = closeConfirmed

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          closeConfirmed
                              ? 'Purchase saved and closed!'
                              : 'Purchase saved but not closed!',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Purchase',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditItem(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
