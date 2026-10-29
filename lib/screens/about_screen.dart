import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});


  static const String _nombre = 'Henry Abrahan Romero Mejia';
  static const String _profesion = 'Desarrollador de software';
  static const String _email = 'henryromerom@gmail.com';
  static const String _telefono = '+1 829 757 0282';
  static const String _fotoAsset = 'assets/icon/foto.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),


            CircleAvatar(
              radius: 80,
              backgroundImage: const AssetImage(_fotoAsset),
              backgroundColor: Colors.teal.shade100,
            ),
            const SizedBox(height: 20),


            Text(
              _nombre,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _profesion,
              style: const TextStyle(fontSize: 16, color: Colors.teal),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),


            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Datos de Contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _infoTile(
                      icon: Icons.email,
                      label: 'Correo',
                      value: _email,
                    ),
                    _infoTile(
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: _telefono,
                    ),


                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: Colors.teal.shade50,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.work_outline, size: 48, color: Colors.teal),
                    SizedBox(height: 10),
                    Text(
                      'Disponible para proyectos freelance y oportunidades laborales',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Desarrollo de software, aplicaciones móviles con Flutter, '
                          'integración de APIs REST y soluciones multiplataforma.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }


  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}