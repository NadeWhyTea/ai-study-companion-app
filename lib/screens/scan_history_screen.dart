import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../services/ocr_session.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final scans = OcrSession.scans;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Scans"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF478DE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: scans.isEmpty
            ? const Center(
          child: Text(
            "No scans yet.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: scans.length,
            itemBuilder: (context, index) {
              if (index >= scans.length) return const SizedBox.shrink(); // safety
              final scan = scans[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(
                    scan.length > 50
                        ? "${scan.substring(0, 50)}..."
                        : scan,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(scan),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Scan?"),
                          content: const Text(
                              "Are you sure you want to delete this scan?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  OcrSession.scans.removeAt(index);
                                });
                                Navigator.pop(ctx);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
