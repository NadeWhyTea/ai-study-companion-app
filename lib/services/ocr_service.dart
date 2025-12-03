import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads the image, calls Cloud Function, and returns the extracted text
  Future<String> extractText(
      XFile pickedFile, {
        Function(double progress, String message)? onProgress,
      }) async {
    try {
      onProgress?.call(0.2, "Uploading image to Firebase...");
      debugPrint("🟩 Upload starting...");

      final fileName =
          'ocr_uploads/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      if (kIsWeb) {
        Uint8List bytes = await pickedFile.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(pickedFile.path));
      }

      final imageUrl = await ref.getDownloadURL();
      onProgress?.call(0.5, "Calling Cloud Function...");
      debugPrint("🟨 Upload complete. Image URL: $imageUrl");

      final callable = _functions.httpsCallable('extractTextFromImage');
      final result = await callable.call({'imageUrl': imageUrl});

      onProgress?.call(0.8, "Finalizing results...");
      debugPrint("🟦 Cloud Function completed. Result: ${result.data}");

      await ref.delete(); // cleanup
      debugPrint("🗑 Temporary file deleted from Firebase Storage.");

      final data = result.data;
      if (data == null || data['text'] == null) {
        throw Exception('OCR function returned no text.');
      }

      onProgress?.call(1.0, "Completed successfully!");
      return data['text'] as String;
    } catch (e, stackTrace) {
      debugPrint("OCR Service Error: $e");
      debugPrint(stackTrace.toString());
      onProgress?.call(1.0, "Failed during processing.");
      return 'Error: Could not extract text from image.';
    }
  }

  void dispose() {}
}