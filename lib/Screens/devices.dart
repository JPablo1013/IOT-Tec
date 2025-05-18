import 'package:flutter/material.dart';
//import 'package:iot/Screens/camera.dart';
import 'package:iot/Screens/control.dart';
import 'package:iot/screens/airesAcondicionados.dart';
import 'lab.dart'; // Importa tu screen de Laboratorios

class DevicesScreen extends StatefulWidget {
  final String username;

  const DevicesScreen({super.key, required this.username});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _deviceGrid(), // Pantalla principal de dispositivos
      const Center(child: Text('Seguridad')), // Placeholder
      LaboratoriosScreen(), // Aquí llamas a tu nuevo screen
      const Center(child: Text('Perfil')), // Placeholder
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Dispositivos'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _deviceGrid() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          DeviceCard(
            icon: Icons.ac_unit,
            label: 'Aire Acondicionado',
            isActive: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AiresScreen(username: widget.username),
                ),
              );
            },
          ),
          DeviceCard(
          icon: Icons.videocam,
          label: 'Cámara',
          onTap: () {
            //Navigator.push(
              //context,
              //MaterialPageRoute(builder: (context) => const CameraViewScreen(cameraUrl: 'http://192.168.1.37',)),
            //);
          },
        ),

          DeviceCard(
            icon: Icons.lightbulb,
            label: 'Luces',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Controlar Luces')),
              );
            },
          ),
          DeviceCard(
          icon: Icons.settings_remote,
          label: 'Control',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ControlScreen()),
            );
          },
        ),

        ],
      ),
    );
  }
}

class DeviceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.deepPurple.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.deepPurple : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
