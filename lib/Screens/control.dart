import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ControlScreen extends StatefulWidget {
  const ControlScreen({Key? key}) : super(key: key);

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final String esp32Ip = 'http://192.168.1.36'; // Cambia esto si tu IP cambia
  String mensaje = 'Selecciona un dispositivo para controlar';
  String codigoHex = '';
  String dispositivoSeleccionado = 'Televisión';

  final List<String> dispositivos = ['Televisión', 'Proyector', 'Aire acondicionado'];

  Future<void> enviarComando(String ruta) async {
    final url = Uri.parse('$esp32Ip/$ruta');
    try {
      final res = await http.get(url);
      setState(() {
        if (res.statusCode == 200) {
          mensaje = '✅ Señal enviada a: $ruta';
          final body = res.body;

          // Buscar si hay un código hexadecimal en la respuesta
          final regex = RegExp(r'0x[0-9A-Fa-f]+');
          final match = regex.firstMatch(body);

          if (match != null) {
            codigoHex = '📥 Código recibido: ${match.group(0)}';
          } else {
            codigoHex = 'ℹ️ No se recibió código hexadecimal.';
          }
        } else {
          mensaje = '⚠️ Error ${res.statusCode}';
          codigoHex = '';
        }
      });
    } catch (e) {
      setState(() {
        mensaje = '❌ Error de conexión: $e';
        codigoHex = '';
      });
    }
  }

  Widget botonControl(String texto, IconData icono, String ruta) {
    return ElevatedButton.icon(
      onPressed: () => enviarComando(ruta),
      icon: Icon(icono),
      label: Text(texto),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget buildControlesTV() {
    return Column(
      children: [
        botonControl('Encender / Apagar TV', Icons.power_settings_new, 'tv/power'),
      ],
    );
  }

  Widget buildControlesProyector() {
    return Column(
      children: [
        botonControl('Encender / Apagar Proyector', Icons.power_settings_new, 'projector/power'),
      ],
    );
  }

  Widget buildControlesAC() {
    return Column(
      children: [
        botonControl('Encender / Apagar AC', Icons.power_settings_new, 'ac/power'),
      ],
    );
  }

  Widget buildControles() {
    switch (dispositivoSeleccionado) {
      case 'Televisión':
        return buildControlesTV();
      case 'Proyector':
        return buildControlesProyector();
      case 'Aire acondicionado':
        return buildControlesAC();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control Remoto')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mensaje, textAlign: TextAlign.left),
            const SizedBox(height: 10),
            Text(codigoHex, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: dispositivoSeleccionado,
              items: dispositivos
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  dispositivoSeleccionado = value!;
                  mensaje = 'Control seleccionado: $value';
                  codigoHex = '';
                });
              },
            ),
            const SizedBox(height: 20),
            buildControles(),
          ],
        ),
      ),
    );
  }
}
