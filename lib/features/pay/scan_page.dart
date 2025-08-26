import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('掃描 QR')),
      body: MobileScanner(
        onDetect: (capture) {
          final codes = capture.barcodes;
          if (codes.isNotEmpty) {
            final raw = codes.first.rawValue ?? '';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('掃到：$raw')));
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
