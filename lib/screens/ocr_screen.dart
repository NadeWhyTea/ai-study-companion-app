import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ocr_service.dart';
import 'dashboard_screen.dart';
import '../services/ocr_session.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final OcrService _ocrService = OcrService();
  String _extractedText = "";
  bool _isLoading = false;
  double _progress = 0.0;
  String _progressMessage = "";
  XFile? _pickedFile;
  Uint8List? _webImageBytes;
  String? _errorMessage;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
          _isLoading = true;
          _errorMessage = null;
          _progress = 0.0;
          _progressMessage = "Preparing image...";
          _extractedText = "";
        });

        if (kIsWeb) _webImageBytes = await pickedFile.readAsBytes();

        setState(() {
          _progress = 0.25;
          _progressMessage = "Uploading image to server...";
        });

        final text = await _ocrService.extractText(
          pickedFile,
          onProgress: (p, msg) {
            setState(() {
              _progress = p;
              _progressMessage = msg;
            });
          },
        );

        setState(() {
          _extractedText = text;
          _isLoading = false;
          _progress = 1.0;
          _progressMessage = "Done!";
        });

      }
    } catch (e, stackTrace) {
      debugPrint("OCR Error: $e");
      debugPrint(stackTrace.toString());
      setState(() {
        _isLoading = false;
        _errorMessage = "Something went wrong while scanning your notes.";
        _extractedText = "";
      });
    }
  }

  void _showFullScreenImage() {
    if (_pickedFile == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black54, // semi-transparent background
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            child: kIsWeb
                ? (_webImageBytes != null
                ? Image.memory(_webImageBytes!, fit: BoxFit.contain)
                : const CircularProgressIndicator())
                : Image.file(File(_pickedFile!.path), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("OCR Scanner"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF478DE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Scan Your Notes",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Use your camera to capture handwritten or printed text. "
                          "Your extracted text will appear below.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                    const SizedBox(height: 30),

                    // Buttons row above preview
                    if (_extractedText.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                "Save Scan",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {
                                if (_extractedText.isNotEmpty) {
                                  OcrSession.scans.add(_extractedText);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Scan saved successfully!")),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              label: const Text(
                                "New Scan",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: _isLoading ? null : _pickImage,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Take Picture button if no picked file
                    if (_pickedFile == null)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt_outlined, size: 24),
                        label: const Text("Take Picture", style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _isLoading ? null : _pickImage,
                      ),

                    // Preview image
                    if (_pickedFile != null)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: _showFullScreenImage,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb
                                  ? (_webImageBytes != null
                                  ? Image.memory(
                                _webImageBytes!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                                  : const SizedBox(
                                height: 200,
                                child: Center(child: Text("Loading preview...")),
                              ))
                                  : Image.file(
                                File(_pickedFile!.path),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showFullScreenImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.black38, // more transparent
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Click to view image",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18, // slightly larger
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Extracted text container
                    if (_pickedFile != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _extractedText.isEmpty ? "No text extracted yet." : _extractedText,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Loading progress
                    if (_isLoading) ...[
                      Text(
                        _progressMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Error message
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}