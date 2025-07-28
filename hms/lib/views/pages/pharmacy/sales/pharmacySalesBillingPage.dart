import 'package:flutter/material.dart';
import 'package:hms/views/pages/pharmacy/sales/generateAndPrintPdf.dart';
import 'package:intl/intl.dart';

class PharmacySalesBillingPage extends StatefulWidget {
  const PharmacySalesBillingPage({Key? key}) : super(key: key);

  @override
  State<PharmacySalesBillingPage> createState() =>
      _PharmacySalesBillingPageState();
}

class _PharmacySalesBillingPageState extends State<PharmacySalesBillingPage> {
  final _formKey = GlobalKey<FormState>();
  final _medicineFocusNode = FocusNode();

  String patientType = 'Outpatient';
  String? selectedInsuranceType;
  String billingType = 'Cash';
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController wardController = TextEditingController();
  final TextEditingController bedController = TextEditingController();
  final TextEditingController patientIdController = TextEditingController();
  final TextEditingController insuranceNumberController =
      TextEditingController();

  final List<Map<String, dynamic>> salesItems = [];

  // Dummy medicine master list with chemical names
  final List<Map<String, String>> medicineMasterList = [
    {'name': 'Paracetamol', 'chemical': 'Acetaminophen'},
    {'name': 'Amoxicillin', 'chemical': 'Amoxicillin Trihydrate'},
    {'name': 'Cough Syrup', 'chemical': 'Dextromethorphan'},
    {'name': 'Ibuprofen', 'chemical': 'Ibuprofen'},
    {'name': 'Metformin', 'chemical': 'Metformin Hydrochloride'},
  ];

  final TextEditingController medicineController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController taxController = TextEditingController();

  bool _isSaving = false;

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  double get subTotal {
    double total = 0;
    for (var item in salesItems) {
      final qty = item['qty'] as double;
      final rate = item['rate'] as double;
      total += qty * rate;
    }
    return total;
  }

  double get totalTax {
    double total = 0;
    for (var item in salesItems) {
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

    // Check if medicine exists in master list by name or chemical (wild search)
    final match = medicineMasterList.firstWhere(
      (med) =>
          med['name']!.toLowerCase() == medicineName.toLowerCase() ||
          med['chemical']!.toLowerCase() == medicineName.toLowerCase(),
      orElse: () => {},
    );

    if (match.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid medicine name or chemical name'),
        ),
      );
      return;
    }

    setState(() {
      // Check for duplicates and update quantity instead of adding duplicate
      final index = salesItems.indexWhere(
        (item) => item['medicine'].toLowerCase() == medicineName.toLowerCase(),
      );
      if (index >= 0) {
        salesItems[index]['qty'] += qty;
        salesItems[index]['rate'] = rate;
        salesItems[index]['tax'] = tax;
      } else {
        salesItems.add({
          'medicine': medicineName,
          'qty': qty,
          'rate': rate,
          'tax': tax,
        });
      }

      medicineController.clear();
      qtyController.clear();
      rateController.clear();
      taxController.clear();

      FocusScope.of(context).requestFocus(_medicineFocusNode);
    });
  }

  void removeItem(int index) {
    setState(() {
      salesItems.removeAt(index);
    });
  }

  Future<void> saveSale() async {
    if (_formKey.currentState!.validate() && salesItems.isNotEmpty) {
      setState(() {
        _isSaving = true;
      });

      // Simulate saving delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Save sale data to database or API here

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sale saved successfully!')));
      Navigator.pop(context);
      await generateAndPrintPdf(
        patientName: patientNameController.text,
        patientType: patientType,
        ward: wardController.text,
        bed: bedController.text,
        patientId: patientIdController.text,
        insuranceType: selectedInsuranceType,
        insuranceNumber: insuranceNumberController.text,
        billingType: billingType,
        salesItems: salesItems,
        totalAmount: totalAmount,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields and add at least one item',
          ),
        ),
      );
    }
  }

  // Medicine search/filter logic
  Iterable<String> medicineOptions(String pattern) {
    return medicineMasterList
        .where(
          (med) =>
              med['name']!.toLowerCase().contains(pattern.toLowerCase()) ||
              med['chemical']!.toLowerCase().contains(pattern.toLowerCase()),
        )
        .map((med) => med['name']!);
  }

  @override
  void dispose() {
    patientNameController.dispose();
    wardController.dispose();
    bedController.dispose();
    patientIdController.dispose();
    insuranceNumberController.dispose();
    medicineController.dispose();
    qtyController.dispose();
    rateController.dispose();
    taxController.dispose();
    _medicineFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales / Billing'),
        backgroundColor: Colors.indigo,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Patient Type
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Outpatient'),
                      value: 'Outpatient',
                      groupValue: patientType,
                      onChanged: (val) => setState(() => patientType = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Inpatient'),
                      value: 'Inpatient',
                      groupValue: patientType,
                      onChanged: (val) => setState(() => patientType = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Patient Name
              TextFormField(
                controller: patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient / Customer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter patient name'
                    : null,
              ),
              const SizedBox(height: 12),

              // Show Ward, Bed, Patient ID inputs only if Inpatient selected
              if (patientType == 'Inpatient') ...[
                TextFormField(
                  controller: wardController,
                  decoration: const InputDecoration(
                    labelText: 'Ward',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Enter ward' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: bedController,
                  decoration: const InputDecoration(
                    labelText: 'Bed',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Enter bed' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: patientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Patient ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter patient ID'
                      : null,
                ),
                const SizedBox(height: 12),
              ],

              // Insurance claim option
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Insurance Type (if any)',
                  border: OutlineInputBorder(),
                ),
                items: ['None', 'ESI', 'Private Insurance', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                value: selectedInsuranceType ?? 'None',
                onChanged: (val) => setState(() => selectedInsuranceType = val),
              ),
              const SizedBox(height: 12),

              if (selectedInsuranceType != null &&
                  selectedInsuranceType != 'None') ...[
                TextFormField(
                  controller: insuranceNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Insurance Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Enter insurance number'
                      : null,
                ),
                const SizedBox(height: 12),
              ],

              // Medicine autocomplete input + qty + rate + tax + add button
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return medicineOptions(textEditingValue.text);
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            medicineController.text = controller.text;
                            return TextFormField(
                              controller: medicineController,
                              focusNode: _medicineFocusNode,
                              decoration: const InputDecoration(
                                labelText: 'Medicine Name / Chemical',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter medicine name';
                                }
                                return null;
                              },
                            );
                          },
                      onSelected: (selection) {
                        medicineController.text = selection;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Qty',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Enter qty';
                        final n = double.tryParse(value);
                        if (n == null || n <= 0) return 'Invalid qty';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: rateController,
                      decoration: const InputDecoration(
                        labelText: 'Rate',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Enter rate';
                        final n = double.tryParse(value);
                        if (n == null || n <= 0) return 'Invalid rate';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: taxController,
                      decoration: const InputDecoration(
                        labelText: 'Tax %',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty)
                          return 'Enter tax %';
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
                child: salesItems.isEmpty
                    ? const Center(child: Text('No items added'))
                    : ListView.builder(
                        itemCount: salesItems.length,
                        itemBuilder: (context, index) {
                          final item = salesItems[index];
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Billing Type',
                  border: OutlineInputBorder(),
                ),
                value: billingType,
                items: ['Cash', 'Credit'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    billingType = val!;
                  });
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isSaving ? null : saveSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Sale', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
