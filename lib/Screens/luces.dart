import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart'; // Para escanear QR

class LucesScreen extends StatefulWidget {
  const LucesScreen({super.key});

  @override
  State<LucesScreen> createState() => _LucesScreen();
}

class _LucesScreen extends State<LucesScreen> {
  String esp32Url = ""; // Ahora se establecerá desde el QR
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
                  Navigator.pop(ctx); // Cierra el diálogo
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control de Relés ESP")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón para escanear QR
              ElevatedButton(
                onPressed: _scanQR,
                child: const Text("Escanear código QR"),
              ),
              
              const SizedBox(height: 20),
              
              // Estado de conexión
              Text(
                isConnected 
                  ? "Conectado a: $esp32Url" 
                  : "No conectado",
                style: TextStyle(
                  color: isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Controles de relés (solo visibles si hay conexión)
              if (isConnected) ...[
                const Text("Control Relé 1"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _controlRelay("on1"),
                      child: const Text("Encender"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _controlRelay("off1"),
                      child: const Text("Apagar"),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                const Text("Control Relé 2"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _controlRelay("on2"),
                      child: const Text("Encender"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _controlRelay("off2"),
                      child: const Text("Apagar"),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}