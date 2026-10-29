import 'package:flutter/material.dart';
import 'gender_screen.dart';
import 'random_user_screen.dart';
import 'universities_screen.dart';
import 'weather_screen.dart';
import 'pokemon_screen.dart';
import 'wordpress_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplicación Multi-Herramientas'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Acerca de',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange.shade100, Colors.orange.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Icon(
                Icons.home_repair_service,
                size: 180,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Selecciona una herramienta para comenzar',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            _buildMenuCard(
              context,
              icon: Icons.wb_sunny,
              title: 'Clima en RD',
              subtitle: 'Pronóstico del día actual',
              color: Colors.orange,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WeatherScreen())),
            ),
            _buildMenuCard(
              context,
              icon: Icons.person_search,
              title: 'Predecir Género',
              subtitle: 'Ingresa un nombre y descubre el género',
              color: Colors.pink,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GenderScreen())),
            ),
            _buildMenuCard(
              context,
              icon: Icons.people,
              title: 'Usuario Aleatorio',
              subtitle: 'Obtén datos de una persona al azar',
              color: Colors.blue,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RandomUserScreen())),
            ),
            _buildMenuCard(
              context,
              icon: Icons.school,
              title: 'Universidades',
              subtitle: 'Busca universidades por país',
              color: Colors.green,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UniversitiesScreen())),
            ),
            _buildMenuCard(
              context,
              icon: Icons.catching_pokemon,
              title: 'Pokémon',
              subtitle: 'Busca un Pokémon y escucha su sonido',
              color: Colors.red,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PokemonScreen())),
            ),
            _buildMenuCard(
              context,
              icon: Icons.rss_feed,
              title: 'Noticias WordPress',
              subtitle: 'Últimas noticias de un sitio WordPress',
              color: Colors.indigo,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WordpressScreen())),
            ),
            _buildMenuCard(
              context,
              icon: Icons.contact_mail,
              title: 'Acerca de',
              subtitle: 'Información de contacto del desarrollador',
              color: Colors.teal,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}