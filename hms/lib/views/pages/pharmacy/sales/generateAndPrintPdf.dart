import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generateAndPrintPdf({
  required String patientName,
  required String patientType,
  String? ward,
  String? bed,
  String? patientId,
  String? insuranceType,
  String? insuranceNumber,
  required String billingType,
  required List<Map<String, dynamic>> salesItems,
  required double totalAmount,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Pharmacy Bill',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Patient Name: $patientName'),
            pw.Text('Patient Type: $patientType'),
            if (patientType == 'Inpatient') ...[
              if (ward != null) pw.Text('Ward: $ward'),
              if (bed != null) pw.Text('Bed: $bed'),
              if (patientId != null) pw.Text('Patient ID: $patientId'),
            ],
            pw.Text('Insurance: ${insuranceType ?? 'None'}'),
            if (insuranceType != null &&
                insuranceType != 'None' &&
                insuranceNumber != null)
              pw.Text('Insurance Number: $insuranceNumber'),
            pw.Text('Billing Type: $billingType'),
            pw.Divider(),
            pw.Text(
              'Items:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.ListView.builder(
              itemCount: salesItems.length,
              itemBuilder: (context, index) {
                final item = salesItems[index];
                final qty = item['qty'] as double;
                final rate = item['rate'] as double;
                final tax = item['tax'] as double;
                final subTotal = qty * rate;
                final taxAmt = subTotal * tax / 100;
                final total = subTotal + taxAmt;

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${item['medicine']}'),
                    pw.Text('Qty: $qty, Rate: ₹$rate, Tax: $tax%'),
                    pw.Text(
                      'Subtotal: ₹${subTotal.toStringAsFixed(2)}, Tax: ₹${taxAmt.toStringAsFixed(2)}, Total: ₹${total.toStringAsFixed(2)}',
                    ),
                    pw.SizedBox(height: 5),
                  ],
                );
              },
            ),
            pw.Divider(),
            pw.Text(
              'Grand Total: ₹${totalAmount.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Thank you for your purchase!'),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
