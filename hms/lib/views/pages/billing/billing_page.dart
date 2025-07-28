import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/dbservices/BillingItemModel.dart';
import 'package:hms/dbservices/HospitalInvoiceItem.dart';
import 'package:hms/dbservices/patientModel.dart';
import 'package:hms/views/pages/billing/BillingEntryForm.dart';

class HospitalBillingPage extends StatefulWidget {
  @override
  _HospitalBillingPageState createState() => _HospitalBillingPageState();
}

class _HospitalBillingPageState extends State<HospitalBillingPage> {
  String selectedPatientType = 'Inpatient';
  String? selectedPatient;
  List<BillingItem> items = [];
  String? selectedPatientId;

  double insurancePercent = 0;
  double flatDiscount = 0;
  double taxPercent = 0;
  String admissionId = '';
  String block = '';
  String ward = '';
  String bedNumber = '';
  DateTime billingDate = DateTime.now();
  final List<String> services = [
    'Pharmacy',
    'Lab Test',
    'Consultation',
    'Bed Charge',
    'Other',
  ];
  final List<Patient> patientsList = [
    Patient(id: '1', name: 'John Doe'),
    Patient(id: '2', name: 'Mary Jane'),
  ];
  String get formattedBillingDate =>
      '${billingDate.day}/${billingDate.month}/${billingDate.year}';

  Future<void> selectBillingDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: billingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != billingDate) {
      setState(() {
        billingDate = pickedDate;
      });
    }
  }

  void addItem(BillingItem item) {
    setState(() => items.add(item));
  }

  void removeItem(int index) {
    setState(() => items.removeAt(index));
  }

  Invoice get invoice => Invoice(
    items: items
        .map(
          (e) => InvoiceItem(
            description: '${e.category}: ${e.description}',
            cost: e.unitPrice * e.quantity,
          ),
        )
        .toList(),
    insuranceCoveragePercent: insurancePercent,
    discountAmount: flatDiscount,
    taxPercent: taxPercent,
  );

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Hospital Billing'),
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 250,
                      ), // adjust as needed
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Billing Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        initialValue: formattedBillingDate,
                        onTap: () => selectBillingDate(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ...['Inpatient', 'Outpatient'].map((type) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: selectedPatientType == type,
                          onSelected: (_) =>
                              setState(() => selectedPatientType = type),
                        ),
                      );
                    }).toList(),
                  ],
                ),

                const SizedBox(height: 12),

                FlexibleDropdown<String>(
                  items: patientsList.map((e) => e.name).toList(),
                  selectedId: selectedPatientId,
                  label: 'Select Patient',
                  idSelector: (name) => name,
                  displaySelector: (name) => name,
                  onChanged: (newName) {
                    setState(() => selectedPatientId = newName);
                  },
                  hintText: 'Search or type patient name',
                ),

                const SizedBox(height: 12),
                if (selectedPatientType == 'Inpatient') ...[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Admission ID'),
                    onChanged: (val) => admissionId = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Block'),
                    onChanged: (val) => block = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Ward'),
                    onChanged: (val) => ward = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Bed Number'),
                    onChanged: (val) => bedNumber = val,
                  ),
                ],
                const SizedBox(height: 16),
                BillingEntryForm(services: services, onAdd: addItem),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Insurance (%)'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(
                          () => insurancePercent = double.tryParse(val) ?? 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Flat Discount'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(
                          () => flatDiscount = double.tryParse(val) ?? 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Tax (%)'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(
                          () => taxPercent = double.tryParse(val) ?? 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text('${item.category} - ${item.description}'),
                        subtitle: Text(
                          '${item.quantity} × ₹${item.unitPrice.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₹${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => removeItem(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Divider(thickness: 1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal: ₹${invoice.subtotal.toStringAsFixed(2)}'),
                    Text(
                      'Insurance: -₹${invoice.insuranceDiscount.toStringAsFixed(2)}',
                    ),
                    Text(
                      'Discount: -₹${invoice.discountAmount.toStringAsFixed(2)}',
                    ),
                    Text('Tax: +₹${invoice.tax.toStringAsFixed(2)}'),
                    Text(
                      'Total Payable: ₹${invoice.totalPayable.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.print),
                      label: Text('Print'),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text('Save Bill'),
                      onPressed: () {},
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
