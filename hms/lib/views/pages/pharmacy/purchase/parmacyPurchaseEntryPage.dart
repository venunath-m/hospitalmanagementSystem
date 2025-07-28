import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/fireStore_service/customer_service.dart';
import 'package:intl/intl.dart';

class PharmacyPurchaseEntryPage extends StatefulWidget {
  const PharmacyPurchaseEntryPage({Key? key}) : super(key: key);

  @override
  State<PharmacyPurchaseEntryPage> createState() =>
      _PharmacyPurchaseEntryPageState();
}

class _PharmacyPurchaseEntryPageState extends State<PharmacyPurchaseEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _medicineFocusNode = FocusNode();

  String? selectedSupplier;
  final List<Map<String, dynamic>> purchaseItems = [];

  // Dummy medicine master list (replace with actual data)
  final List<String> medicineMasterList = [
    'Paracetamol',
    'Amoxicillin',
    'Cough Syrup',
    'Ibuprofen',
    'Metformin',
  ];

  // Controllers for new item inputs
  final TextEditingController medicineController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController taxController = TextEditingController();

  bool _isSaving = false;

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  // Calculate totals
  double get subTotal {
    double total = 0;
    for (var item in purchaseItems) {
      final qty = item['qty'] as double;
      final rate = item['rate'] as double;
      total += qty * rate;
    }
    return total;
  }

  double get totalTax {
    double total = 0;
    for (var item in purchaseItems) {
      final qty = item['qty'] as double;
      final rate = item['rate'] as double;
      final tax = item['tax'] as double;
      total += qty * rate * (tax / 100);
    }
    return total;
  }

  double get totalAmount => subTotal + totalTax;

  void addItem() {
    final medicineName = medicineController.text.trim();
    final qty = double.tryParse(qtyController.text.trim());
    final rate = double.tryParse(rateController.text.trim());
    final tax = double.tryParse(taxController.text.trim());

    if (medicineName.isEmpty || qty == null || rate == null || tax == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all item fields with valid values'),
        ),
      );
      return;
    }
    if (qty <= 0 || rate <= 0 || tax < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quantity and Rate must be > 0 and Tax ≥ 0'),
        ),
      );
      return;
    }
    if (!medicineMasterList.contains(medicineName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medicine from the list')),
      );
      return;
    }

    setState(() {
      // Check for duplicate medicine - update if exists
      final index = purchaseItems.indexWhere(
        (item) => item['medicine'] == medicineName,
      );
      if (index >= 0) {
        purchaseItems[index]['qty'] += qty;
        purchaseItems[index]['rate'] = rate;
        purchaseItems[index]['tax'] = tax;
      } else {
        purchaseItems.add({
          'medicine': medicineName,
          'qty': qty,
          'rate': rate,
          'tax': tax,
        });
      }

      // Clear inputs & focus medicine field
      medicineController.clear();
      qtyController.clear();
      rateController.clear();
      taxController.clear();
      FocusScope.of(context).requestFocus(_medicineFocusNode);
    });
  }

  void removeItem(int index) {
    setState(() {
      purchaseItems.removeAt(index);
    });
  }

  Future<void> savePurchase() async {
    if (_formKey.currentState!.validate() && purchaseItems.isNotEmpty) {
      setState(() {
        _isSaving = true;
      });

      // Simulate saving delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual save logic here

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase saved successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select supplier and add at least one item'),
        ),
      );
    }
  }

  @override
  void dispose() {
    medicineController.dispose();
    qtyController.dispose();
    rateController.dispose();
    taxController.dispose();
    _medicineFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: CustomAppBar(
        title: 'Purchase Entry',
        backgroundColor: Colors.indigo,
      ),
      // resizeToAvoidBottomInset: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Supplier Dropdown (replace with your supplier data)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Supplier',
                  border: OutlineInputBorder(),
                ),
                items: ['Supplier A', 'Supplier B', 'Supplier C']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => selectedSupplier = val),
                validator: (val) =>
                    val == null ? 'Please select a supplier' : null,
              ),
              const SizedBox(height: 16),

              // Medicine autocomplete field
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty)
                    return const Iterable<String>.empty();
                  return medicineMasterList.where(
                    (med) => med.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      medicineController.text = controller.text;
                      return TextFormField(
                        controller: medicineController,
                        focusNode: _medicineFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter medicine name';
                          }
                          if (!medicineMasterList.contains(value.trim())) {
                            return 'Please select a medicine from the list';
                          }
                          return null;
                        },
                      );
                    },
                onSelected: (selection) {
                  medicineController.text = selection;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Please enter quantity';
                        final n = double.tryParse(value);
                        if (n == null || n <= 0) return 'Invalid quantity';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: rateController,
                      decoration: const InputDecoration(
                        labelText: 'Rate',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Please enter rate';
                        final n = double.tryParse(value);
                        if (n == null || n <= 0) return 'Invalid rate';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: taxController,
                      decoration: const InputDecoration(
                        labelText: 'Tax %',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Please enter tax %';
                        final n = double.tryParse(value);
                        if (n == null || n < 0) return 'Invalid tax';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: addItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // List of added items
              SizedBox(
                height: 250,
                child: purchaseItems.isEmpty
                    ? const Center(child: Text('No items added'))
                    : ListView.builder(
                        itemCount: purchaseItems.length,
                        itemBuilder: (context, index) {
                          final item = purchaseItems[index];
                          final subTotalItem = item['qty'] * item['rate'];
                          final taxAmountItem =
                              subTotalItem * (item['tax'] / 100);
                          final totalItem = subTotalItem + taxAmountItem;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(item['medicine']),
                              subtitle: Text(
                                'Qty: ${item['qty']}, Rate: ${currencyFormat.format(item['rate'])}, Tax: ${item['tax']}%\nSubtotal: ${currencyFormat.format(subTotalItem)}, Tax Amt: ${currencyFormat.format(taxAmountItem)}, Total: ${currencyFormat.format(totalItem)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => removeItem(index),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // Totals display
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Subtotal: ${currencyFormat.format(subTotal)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Tax Total: ${currencyFormat.format(totalTax)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Total Amount: ${currencyFormat.format(totalAmount)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isSaving ? null : savePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Purchase',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
