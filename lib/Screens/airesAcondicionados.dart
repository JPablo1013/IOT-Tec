import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class AiresScreeen extends StatefulWidget {
  const AiresScreeen({super.key});

  @override
  State<AiresScreeen> createState() => _AiresScreeenState();
}

class _AiresScreeenState extends State<AiresScreeen> {
  String esp32Url = "";
  bool isConnected = false;
  MobileScannerController cameraController = MobileScannerController();

  Future<void> _scanQR() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Escanea el código QR"),
        content: SizedBox(
          height: 300,
          width: 300,
          child: MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(ctx);
                  _processScannedIP(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cameraController.stop();
            },
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  void _processScannedIP(String ipFromQR) {
    setState(() {
      esp32Url = "http://$ipFromQR";
      isConnected = true;
    });
  }

  Future<void> _controlRelay(String endpoint) async {
    if (esp32Url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero escanea el código QR")),
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse('$esp32Url/$endpoint'));
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Widget airControl(String title, String onCmd, String offCmd) {
    return Column(
      children: [
        Icon(Icons.ac_unit, size: 60, color: Colors.white),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(fontSize: 18, color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _controlRelay(onCmd),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Encender"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _controlRelay(offCmd),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Apagar"),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control de Aires"),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _scanQR,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text("Escanear código QR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isConnected
                      ? "Conectado a: $esp32Url"
                      : "No conectado",
                  style: TextStyle(
                    color: isConnected ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                if (isConnected) ...[
                  airControl("Aire 1", "on1", "off1"),
                  const SizedBox(height: 30),
                  airControl("Aire 2", "on2", "off2"),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
