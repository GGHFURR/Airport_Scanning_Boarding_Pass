import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'ScanResultPage.dart';
import 'get_started_page.dart'; // Pastikan Anda mengimpor halaman GetStartedPage

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  bool isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Memulai pemindaian barcode segera setelah halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBarcodeScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Future<void> _startBarcodeScan() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on Exception {
      barcodeScanRes = 'Failed to get barcode.';
    }

    if (!mounted) return;

    if (barcodeScanRes != '-1' && barcodeScanRes != 'Failed to get barcode.') {
      _navigateToScanResultPage(barcodeScanRes);
    } else {
      // Kembali ke halaman GetStartedPage jika pemindaian gagal atau dibatalkan
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GetStartedPage()),
        (route) => false,
      );
    }
  }

  void _navigateToScanResultPage(String code) async {
    if (!isNavigating) {
      setState(() {
        isNavigating = true;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultPage(
            rawpnr: code,
            token: '',
          ),
        ),
      );

      setState(() {
        isNavigating = false;
      });
    }
  }
}
