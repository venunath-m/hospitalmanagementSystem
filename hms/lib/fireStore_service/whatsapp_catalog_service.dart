import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> fetchWhatsAppCatalogAndSave() async {
  const String accessToken = 'YOUR_TEMPORARY_ACCESS_TOKEN';
  const String phoneNumberId = 'YOUR_PHONE_NUMBER_ID';

  final url = 'https://graph.facebook.com/v19.0/$phoneNumberId/catalog';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final catalogData = json.decode(response.body);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('whatsapp_catalog').add({
        'data': catalogData,
        'fetchedAt': Timestamp.now(),
      });

      return "Catalog fetched and saved successfully.";
    } else {
      return "Failed: ${response.statusCode} - ${response.body}";
    }
  } catch (e) {
    return "Error: $e";
  }
}
