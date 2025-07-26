import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// Web import
import 'dart:html' as html;

// Mobile import (wrap in conditional imports if needed)
import 'dart:io' as io;

class ImageUploaderService {
  /// Opens image picker and uploads image to Firebase.
  ///
  /// - [context]: Required for showing any messages (optional).
  /// - [folderName]: The folder path in Firebase storage (e.g., 'company_logos').
  ///
  /// Returns the image URL after upload or `null` if failed or cancelled.
  static Future<String?> pickAndUploadImage({
    required BuildContext context,
    required String folderName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '$folderName/${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      if (kIsWeb) {
        final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
        uploadInput.click();

        final completer = Completer<String?>();

        uploadInput.onChange.listen((event) {
          final file = uploadInput.files?.first;
          if (file == null) {
            completer.complete(null);
            return;
          }

          final reader = html.FileReader();

          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((event) async {
            final bytes = reader.result as Uint8List;

            final metadata = SettableMetadata(
              contentType: file.type ?? 'image/png',
            );

            try {
              final snapshot = await ref.putData(bytes, metadata);
              final url = await snapshot.ref.getDownloadURL();
              completer.complete(url);
            } catch (e) {
              print('Web upload error: $e');
              completer.complete(null);
            }
          });

          reader.onError.listen((event) {
            print('Reader error: ${reader.error}');
            completer.complete(null);
          });
        });

        return completer.future;
      } else {
        // For Mobile: Use ImagePicker (optional: integrate yourself)
        // Assume [file] is passed to this function externally if not using ImagePicker directly here
        throw UnimplementedError(
          "Mobile image picking should be handled externally and passed here.",
        );
      }
    } catch (e) {
      print("Upload Failed: $e");
      return null;
    }
  }

  /// Uploads image file (mobile) passed to this method
  static Future<String?> uploadMobileFile({
    required io.File file,
    required String folderName,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '$folderName/${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final snapshot = await ref.putFile(file, metadata);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Mobile upload failed: $e");
      return null;
    }
  }
}
// How to Use (Web)
// String? uploadedImageUrl;

// ElevatedButton(
//   onPressed: () async {
//     final url = await ImageUploaderService.pickAndUploadImage(
//       context: context,
//       folderName: 'company_logos',
//     );

//     if (url != null) {
//       setState(() {
//         uploadedImageUrl = url;
//       });
//     }
//   },
//   child: const Text("Upload Image"),
// ),
//How to Use (Mobile)
// final file = await ImagePicker().pickImage(source: ImageSource.gallery);
// if (file != null) {
//   final uploadedUrl = await ImageUploaderService.uploadMobileFile(
//     file: io.File(file.path),
//     folderName: 'company_logos',
//   );
// }
