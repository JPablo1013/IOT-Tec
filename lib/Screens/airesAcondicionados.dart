import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

class AiresScreen extends StatefulWidget {
  final String username;

  const AiresScreen({super.key, required this.username});

  @override
  State<AiresScreen> createState() => _AiresScreenState();
}

class _AiresScreenState extends State<AiresScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? dispositivoGuardado;

  @override
  void initState() {
    super.initState();
    if (widget.username.isNotEmpty) {
      _cargarDispositivo();
    }
  }

  Future<void> _cargarDispositivo() async {
    final url = Uri.parse(
      'https://domotica-itc-dc7d4-default-rtdb.firebaseio.com/usuarios/${widget.username}/dispositivo.json',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final ip = jsonDecode(response.body);
      setState(() {
        dispositivoGuardado = ip;
      });
    }
  }

  Future<void> _guardarDispositivo(String ip) async {
    if (widget.username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Usuario no válido")),
      );
      return;
    }

    final url = Uri.parse(
      'https://domotica-itc-dc7d4-default-rtdb.firebaseio.com/usuarios/${widget.username}/dispositivo.json',
    );

    final response = await http.put(
      url,
      body: jsonEncode(ip),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      setState(() {
        dispositivoGuardado = ip;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dispositivo guardado.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: ${response.body}")),
      );
    }
  }

  Future<void> _controlRelay(String baseUrl, String cmd) async {
    try {
      final url = Uri.parse('$baseUrl/$cmd');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

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
                  final ip = "http://${barcode.rawValue!}";
                  _guardarDispositivo(ip);
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

  Widget buildDeviceCard(String ip) {
    return Card(
      color: Colors.blue[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Dispositivo: $ip", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _controlRelay(ip, 'on1'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Aire 1 ON"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _controlRelay(ip, 'off1'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Aire 1 OFF"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _controlRelay(ip, 'on2'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Aire 2 ON"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _controlRelay(ip, 'off2'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Aire 2 OFF"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tu Dispositivo"),
        backgroundColor: Colors.blue[800],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDispositivo,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: dispositivoGuardado == null
              ? [
                  const SizedBox(height: 100),
                  const Center(
                    child: Text(
                      "No tienes dispositivo registrado.\nPulsa el botón + para agregar uno.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ]
              : [buildDeviceCard(dispositivoGuardado!)],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQR,
        tooltip: 'Agregar dispositivo',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
