import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:hms/dbservices/companiesModel.dart';
import 'package:hms/fireStore_service/companiesCollection_service.dart';
import 'package:hms/fireStore_service/customer_service.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NewKotInvoicePageSales extends StatefulWidget {
  final String type;
  final Map<String, dynamic> summaryData;
  final List<Map<String, dynamic>> details;

  NewKotInvoicePageSales({
    required this.type,
    required this.summaryData,
    required this.details,
  });

  @override
  _NewKotInvoicePageSalesState createState() => _NewKotInvoicePageSalesState();
}

class _NewKotInvoicePageSalesState extends State<NewKotInvoicePageSales> {
  String? companyName;
  String? companyAddress;
  String? email;
  String? gstin; // Providing a default value if null
  String? logoUrl; // Providing a default value if null
  String? phone; // Providing a default value if null
  String? webSite; // Providing a default value if null
  String? firstLine;
  String? secondLine;
  late String _gstin;
  late String _billingAddress;
  late String _shippingAddress;

  String? bankName;
  String? accountName;
  String? accountNumber;
  String? ifscCode; // Providing a default value if null
  String? branch; // Providing a default value if null
  String? city; // Providing a default value if null
  String? state; // Providing a default value if null
  String? zip;

  bool _isLoading = true;
  final CustomerService _customerService = CustomerService();
  final CompanycollectionService _companyService = CompanycollectionService();
  Company? _company;
  @override
  void initState() {
    super.initState();
    final customerId = widget.summaryData['customerId'] ?? 0;

    if (customerId != 0) {
      _loadCustomerGstin();
    } else {
      setState(() {
        _gstin = 'N/A'; // If no customerId is found
        _billingAddress = 'N/A';
        _shippingAddress = 'N/A';
        _isLoading = false;
      });
    }
  }

  Future<pw.ImageProvider> getLogoImageProvider(String? logoUrl) async {
    try {
      if (logoUrl != null && logoUrl.trim().isNotEmpty) {
        final response = await http.get(Uri.parse(logoUrl));
        if (response.statusCode == 200) {
          final imageBytes = response.bodyBytes;
          return pw.MemoryImage(imageBytes);
        } else {
          print('Network image failed, status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error loading network image: $e');
    }

    // Fallback to asset image
    final fallbackBytes = await rootBundle.load('assets/burjLogo.png');
    return pw.MemoryImage(fallbackBytes.buffer.asUint8List());
  }

  Future<void> _fetchCompany(String companyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final companyId = prefs.getString('companyId');

      // Fetching company data from the service
      final companyData = await _companyService.getCompanyById(companyId!);

      if (companyData != null) {
        // Assuming Company.fromJson method correctly parses the fields from the response
        _company = Company.fromJson(companyData);

        // Extracting the specific fields from the company data
        companyName =
            _company?.companyName ??
            "Unknown Company Name"; // Providing a default value if null
        companyAddress =
            _company?.address ??
            "Unknown Address"; // Providing a default value if null
        email =
            _company?.email ?? "No Email"; // Providing a default value if null
        gstin =
            _company?.gst ?? "No GSTIN"; // Providing a default value if null
        logoUrl =
            _company?.logoUrl ??
            "No Logo URL"; // Providing a default value if null
        phone =
            _company?.phone ?? "No Phone"; // Providing a default value if null
        webSite =
            _company?.website ??
            "No Website"; // Providing a default value if null
        firstLine = companyAddress!.length > 40
            ? companyAddress!.substring(0, 40)
            : companyAddress;

        secondLine = companyAddress!.length > 40
            ? companyAddress!.substring(40)
            : '';

        bankName =
            _company?.bankName ??
            "Unknown Bank Name"; // Providing a default value if null
        accountName =
            _company?.accountName ??
            "Unknown Account Name"; // Providing a default value if null
        accountNumber =
            _company?.accountNumber ??
            "No Account Number"; // Providing a default value if null
        ifscCode =
            _company?.ifscCode ??
            "No IfscCode"; // Providing a default value if null
        branch =
            _company?.branch ??
            "Unknown Branch"; // Providing a default value if null
        city =
            _company?.city ??
            "Unknown City"; // Providing a default value if null
        state =
            _company?.state ??
            "Unknown State"; // Providing a default value if null
        zip =
            _company?.zip ??
            "Unknown ZipCode"; // Providing a default value if null

        // You can now use these values as needed

        // Example of using the extracted data
        // You can save these to variables or display them in your UI
      } else {
        print("No company data found for ID: $companyId");
      }
    } catch (e) {
      print("Error loading company: $e");
    }
  }

  Future<void> _loadCustomerGstin() async {
    // Fetch the GSTIN using the customer ID from summaryData
    final customerId = widget.summaryData['customerId'] ?? 0;
    final customerData = widget.summaryData.toString();
    final userId =
        widget.summaryData['userId']?.toString() ?? ''; // Add this line

    if (customerId != 0) {
      final result = await _customerService.getCustomerGstin(
        userId,
        customerId,
      );

      // Update the state with the fetched GSTIN
      setState(() {
        _gstin = result['gstin'] ?? 'N/A'; // Default to 'N/A' if not found
        _billingAddress = result['address'] ?? 'N/A';
        _shippingAddress = result['shippingAddress'] ?? 'N/A';
        _isLoading = false;
      });
    } else {
      setState(() {
        _gstin = 'N/A'; // If no customerId is found
        _billingAddress = 'N/A';
        _shippingAddress = 'N/A';
        _isLoading = false;
      });
    }
  }

  // Function to build the PDF
  Future<void> _buildPdf() async {
    final pdf = pw.Document();
    final paperSize = PdfPageFormat.a5;
    await _fetchCompany(widget.summaryData['companyId']);

    final logo = await getLogoImageProvider(logoUrl);

    final arabicFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
    );
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          /// Header Row: Logo and Company Info
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Logo and Company Info
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Image(logo, width: 80), // <-- Your logo image
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "$companyName",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text("$firstLine", style: pw.TextStyle(fontSize: 10)),
                  pw.Text("$secondLine", style: pw.TextStyle(fontSize: 10)),
                  pw.Text(
                    "$city, "
                    ", $state, "
                    " ,$zip",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text("$phone", style: pw.TextStyle(fontSize: 10)),
                  pw.Text("$email", style: pw.TextStyle(fontSize: 10)),
                  pw.Text("$webSite", style: pw.TextStyle(fontSize: 10)),
                ],
              ),

              // Title and Invoice Info
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Center(
                    child: pw.Text(
                      "TAX INVOICE",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "Bill No: ${widget.summaryData['billNo'] ?? 'N/A'}",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    "Customer GST No: ${_gstin ?? 'N/A'}",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    "Date: ${DateFormat.yMMMd().format(DateTime.parse(widget.summaryData['billEntryDate'] ?? DateTime.now().toString()))}",
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          /// Billing & Shipping Info
          pw.Text(
            "Bill To:",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Billing Address:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      _billingAddress ?? 'N/A',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Shipping Address:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      _shippingAddress ?? 'N/A',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          /// Invoice Table
          pw.Table.fromTextArray(
            headers: ['Item', 'Qty', 'Rate', 'TaxAmount', 'Amount'],
            data: widget.details.map((e) {
              final itemName = e['itemName'] ?? 'Unknown';
              final price = (e['price'] ?? 0) as num;
              final quantity = (e['quantity'] ?? 0) as num;
              final amount = price * quantity;
              final taxAmount = (e['taxAmount'] ?? 0) as num;
              final itemTotalAmount = (e['itemTotalAmount'] ?? 0) as num;
              final ed = widget.details;
              return [
                itemName ?? '',
                quantity.toString(),
                price.toString(),
                taxAmount.toString(),
                itemTotalAmount.toString(),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: pw.TextStyle(fontSize: 10),
            border: pw.TableBorder.all(),
            cellAlignment: pw.Alignment.centerLeft,
          ),

          pw.SizedBox(height: 20),

          /// Comments and Total
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Other Comments
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Other Comments:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      widget.summaryData['comments'] ?? 'N/A',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              // Total
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "Total: ${widget.summaryData['total'] + widget.summaryData['taxTotal'] ?? 0}",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          /// Bank Details
          pw.Text(
            "Bank Details:",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text("Bank Name: $bankName", style: pw.TextStyle(fontSize: 10)),
          pw.Text(
            "Account Name: $accountName",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "Account Number: $accountNumber",
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.Text("IFSC Code: $ifscCode", style: pw.TextStyle(fontSize: 10)),
          pw.Text("Branch: $branch", style: pw.TextStyle(fontSize: 10)),

          pw.SizedBox(height: 30),

          /// Footer
          pw.Center(
            child: pw.Text(
              "If you have any questions about this invoice, please contact, $companyName, $phone",
              style: pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Center(
            child: pw.Text(
              "Thank You For Your Business!",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.type == 'sales' ? 'Sales' : 'Purchase'} Invoice"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.type == 'sales' ? 'Sales' : 'Purchase'} Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              widget.type == 'sales'
                  ? "Customer: ${widget.summaryData['customerName'] ?? 'Unknown'}"
                  : "Supplier: ${widget.summaryData['supplierName'] ?? 'Unknown'}",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Date: ${DateFormat.yMMMd().format(DateTime.parse(widget.summaryData['billEntryDate'] ?? DateTime.now().toString()))}",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              "Items:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...widget.details.map((e) {
              final itemName = e['itemName'] ?? 'Unknown';
              final price = (e['price'] ?? 0) as num;
              final quantity = (e['quantity'] ?? 0) as num;
              final total = price * quantity;

              return ListTile(
                title: Text("$itemName x $quantity"),
                subtitle: Text("$price each"),
                trailing: Text("${total.toStringAsFixed(2)}"),
              );
            }).toList(),
            Divider(),
            Text(
              "Total: ${widget.summaryData['total'] ?? 0}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _buildPdf,
              child: Text("Reprint Report as PDF"),
            ),
          ],
        ),
      ),
    );
  }
}
