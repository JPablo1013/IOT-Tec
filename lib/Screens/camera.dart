import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key? key}) : super(key: key);

  // Cambia esta IP por la IP real de tu ESP32-CAM
  final String esp32CamIP = 'http://192.168.1.37'; // ✅ Usa tu IP local

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cámara ESP32-CAM'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Transmisión en vivo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: Image.network(
                '$esp32CamIP/stream',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('No se pudo conectar con la cámara');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
