import 'package:flutter/material.dart';

class OcrReviewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> blocks; // {text, confidence, boundingBox}

  const OcrReviewScreen({super.key, required this.blocks});

  @override
  State<OcrReviewScreen> createState() => _OcrReviewScreenState();
}

class _OcrReviewScreenState extends State<OcrReviewScreen> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.blocks
        .map((b) => TextEditingController(text: b['text'] ?? ''))
        .toList();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _finishReview() {
    // Reconstruct text preserving block order
    final fullText = _controllers.map((c) => c.text).join('\n\n');

    // Return back to previous screen with edited text
    Navigator.of(context).pop(fullText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review OCR Text')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Some parts of your scan may be uncertain. '
                  'Please review and correct if needed.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: widget.blocks.length,
                itemBuilder: (context, index) {
                  final block = widget.blocks[index];
                  final confidence = block['confidence'] ?? 1.0;
                  return Card(
                    color: confidence < 0.85 ? Colors.yellow[100] : Colors.green[50],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: _controllers[index],
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Text Block',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _finishReview,
              child: const Text('Finish Review'),
            ),
          ],
        ),
      ),
    );
  }
}
