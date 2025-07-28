// purchase_item_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/purchase_item_model.dart';

class PurchaseItemFormDialog extends StatefulWidget {
  final PurchaseItemModel? initialItem;

  const PurchaseItemFormDialog({Key? key, this.initialItem}) : super(key: key);

  @override
  State<PurchaseItemFormDialog> createState() => _PurchaseItemFormDialogState();
}

class _PurchaseItemFormDialogState extends State<PurchaseItemFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController medicineController;
  late TextEditingController hsnCodeController;
  late TextEditingController qtyController;
  late TextEditingController rateController;
  late TextEditingController saleRateController;
  late TextEditingController batchNoController;
  DateTime? expiryDate;
  late TextEditingController taxPercentController;
  bool taxInclusive = false;

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    medicineController = TextEditingController(text: item?.medicineName ?? '');
    hsnCodeController = TextEditingController(text: item?.hsnCode ?? '');
    qtyController = TextEditingController(
      text: item?.quantity.toString() ?? '',
    );
    rateController = TextEditingController(text: item?.rate.toString() ?? '');
    saleRateController = TextEditingController(
      text: item?.saleRate.toString() ?? '',
    );
    batchNoController = TextEditingController(text: item?.batchNo ?? '');
    expiryDate = item?.expiryDate ?? DateTime.now();
    taxPercentController = TextEditingController(
      text: item?.taxPercent.toString() ?? '',
    );
    taxInclusive = item?.taxInclusive ?? false;
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked != null) {
      setState(() {
        expiryDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final item = PurchaseItemModel(
        medicineName: medicineController.text.trim(),
        hsnCode: hsnCodeController.text.trim(),
        quantity: double.parse(qtyController.text.trim()),
        rate: double.parse(rateController.text.trim()),
        saleRate: double.parse(saleRateController.text.trim()),
        batchNo: batchNoController.text.trim(),
        expiryDate: expiryDate ?? DateTime.now(),
        taxPercent: double.parse(taxPercentController.text.trim()),
        taxInclusive: taxInclusive,
      );
      Navigator.of(context).pop(item);
    }
  }

  @override
  void dispose() {
    medicineController.dispose();
    hsnCodeController.dispose();
    qtyController.dispose();
    rateController.dispose();
    saleRateController.dispose();
    batchNoController.dispose();
    taxPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialItem == null ? 'Add Purchase Item' : 'Edit Purchase Item',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: medicineController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter medicine name'
                    : null,
              ),
              TextFormField(
                controller: hsnCodeController,
                decoration: const InputDecoration(labelText: 'HSN Code'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter HSN code' : null,
              ),
              TextFormField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter quantity';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Quantity must be > 0';
                  return null;
                },
              ),
              TextFormField(
                controller: rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate (Cost Price)',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter rate';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Rate must be > 0';
                  return null;
                },
              ),
              TextFormField(
                controller: saleRateController,
                decoration: const InputDecoration(labelText: 'Sale Rate'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter sale rate';
                  final n = double.tryParse(v);
                  if (n == null || n < 0) return 'Invalid sale rate';
                  return null;
                },
              ),
              TextFormField(
                controller: batchNoController,
                decoration: const InputDecoration(labelText: 'Batch Number'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter batch number' : null,
              ),
              InkWell(
                onTap: _pickExpiryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        expiryDate != null
                            ? dateFormat.format(expiryDate!)
                            : 'Select Date',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: taxPercentController,
                decoration: const InputDecoration(labelText: 'Tax %'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter tax %';
                  final n = double.tryParse(v);
                  if (n == null || n < 0) return 'Invalid tax %';
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Tax Inclusive Price'),
                value: taxInclusive,
                onChanged: (val) => setState(() => taxInclusive = val),
              ),
              const SizedBox(height: 10),
              Builder(
                builder: (_) {
                  final margin =
                      (double.tryParse(saleRateController.text) ?? 0) -
                      (double.tryParse(rateController.text) ?? 0);
                  final marginPercent =
                      (margin / (double.tryParse(rateController.text) ?? 1)) *
                      100;
                  final quantity = double.tryParse(qtyController.text) ?? 0;
                  final rate = double.tryParse(rateController.text) ?? 0;
                  final taxPercent =
                      double.tryParse(taxPercentController.text) ?? 0;

                  final subTotal = taxInclusive
                      ? quantity * (rate / (1 + taxPercent / 100))
                      : quantity * rate;
                  final taxAmount = taxInclusive
                      ? quantity * rate - subTotal
                      : subTotal * (taxPercent / 100);
                  final totalAmount = subTotal + taxAmount;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Margin: ${marginPercent.toStringAsFixed(2)}%'),
                      Text(
                        'Item Total with Tax: ₹${totalAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
