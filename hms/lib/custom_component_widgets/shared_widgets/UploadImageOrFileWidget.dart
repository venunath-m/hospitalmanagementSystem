import 'dart:io' as io;
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';

class UploadImageOrFileWidget extends StatefulWidget {
  final String folderName;

  const UploadImageOrFileWidget({super.key, required this.folderName});

  @override
  State<UploadImageOrFileWidget> createState() =>
      _UploadImageOrFileWidgetState();
}

class _UploadImageOrFileWidgetState extends State<UploadImageOrFileWidget> {
  bool isUploading = false;
  String? uploadedUrl;

  Future<void> _handleUpload() async {
    setState(() {
      isUploading = true;
      uploadedUrl = null;
    });

    String? url;

    if (kIsWeb) {
      url = await ImageUploaderService.pickAndUploadImage(
        context: context,
        folderName: widget.folderName,
      );
    } else {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        url = await ImageUploaderService.uploadMobileFile(
          file: io.File(picked.path),
          folderName: widget.folderName,
        );
      }
    }

    setState(() {
      isUploading = false;
      uploadedUrl = url;
    });

    if (url != null) {
      await PopupMessage.show(
        context,
        title: "Upload Successful",
        message: "Image uploaded successfully.",
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
        autoDismiss: true,
      );
    } else {
      await PopupMessage.show(
        context,
        title: "Upload Failed",
        message: "Failed to upload image. Please try again.",
        icon: Icons.error_outline,
        iconColor: Colors.red,
        autoDismiss: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isUploading)
          Column(
            children: [
              // Animated progress indicator
              const SizedBox(height: 20),
              const SizedBox(
                width: 60,
                height: 60,
                child: LoadingIndicator(
                  indicatorType:
                      Indicator.lineScalePulseOutRapid, // or any style you like
                  colors: [Colors.blue, Colors.purple],
                  strokeWidth: 2,
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Uploading...",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.upload),
            label: const Text("Upload Image"),
            onPressed: _handleUpload,
          ),
        if (uploadedUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                const Text(
                  "Uploaded Image:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Image.network(uploadedUrl!, height: 150, fit: BoxFit.cover),
              ],
            ),
          ),
      ],
    );
  }
}
// HOw to use it 
// UploadImageWidget(
//       folderName: "company_logos",
//     ),