import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  String? _selectedCategory;
  String? _selectedDevice;
  Map<String, dynamic> _devices = {};
  final List<String> _categories = ['teles', 'aires', 'proyectores'];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final url = Uri.parse(
        'https://domotica-itc-dc7d4-default-rtdb.firebaseio.com/dispositivos.json');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _devices = json.decode(response.body) ?? {};
      });
    }
  }

  Future<void> _activarEmision(
      String categoria, String device, String buttonName, bool emitirActual) async {
    if (emitirActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("La señal ya está activa para $buttonName")),
      );
      return;
    }

    final url = Uri.parse(
        'https://domotica-itc-dc7d4-default-rtdb.firebaseio.com/dispositivos/$categoria/$device/botones/$buttonName.json');

    final responseTrue = await http.patch(url, body: json.encode({"emitir": true}));
    if (responseTrue.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Señal activada para $buttonName")),
      );

      await Future.delayed(const Duration(seconds: 5));

      await http.patch(url, body: json.encode({"emitir": false}));

      _loadDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al activar señal para $buttonName")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryDevices = _selectedCategory != null
        ? _devices[_selectedCategory] as Map<String, dynamic>?
        : null;

    final selectedDeviceButtons = _selectedCategory != null &&
            _selectedDevice != null &&
            selectedCategoryDevices?[_selectedDevice]?['botones'] != null
        ? (selectedCategoryDevices![_selectedDevice]['botones']
                as Map<String, dynamic>)
            .entries
            .toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Control de Dispositivos"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text("Selecciona una categoría"),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedDevice = null;
                });
              },
            ),
            const SizedBox(height: 10),
            if (_selectedCategory != null)
              DropdownButton<String>(
                value: _selectedDevice,
                hint: const Text("Selecciona un dispositivo"),
                items: (selectedCategoryDevices?.keys.toList() ?? []).map((key) {
                  return DropdownMenuItem<String>(
                    value: key,
                    child: Text(key),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDevice = value;
                  });
                },
              ),
            const SizedBox(height: 20),
            if (selectedDeviceButtons.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: selectedDeviceButtons.length,
                  itemBuilder: (context, index) {
                    final entry = selectedDeviceButtons[index];
                    final buttonName = entry.key;
                    final buttonData = entry.value;
                    final emitir = buttonData['emitir'] ?? false;
                    final codigoIR = buttonData['codigo_ir'] ?? "";

                    return ListTile(
                      title: Text(buttonName),
                      subtitle: Text("Código IR: $codigoIR"),
                      trailing: emitir
                          ? const Icon(Icons.wifi_tethering, color: Colors.red)
                          : const Icon(Icons.wifi_tethering_off),
                      onTap: () => _activarEmision(
                        _selectedCategory!,
                        _selectedDevice!,
                        buttonName,
                        emitir,
                      ),
                    );
                  },
                ),
              )
            else if (_selectedDevice != null)
              const Text("No hay botones disponibles para este dispositivo."),
          ],
        ),
      ),
    );
  }
}
