import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, dynamic>? _pokemon;
  bool _loading = false;
  String? _error;

  Future<void> _fetchPokemon() async {
    final name = _controller.text.trim().toLowerCase();
    if (name.isEmpty) {
      setState(() => _error = 'Ingresa el nombre de un Pokémon');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _pokemon = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() => _pokemon = jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        setState(() => _error = 'Pokémon no encontrado');
      } else {
        setState(() => _error = 'Error al consultar la API');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _playSound() async {
    if (_pokemon == null) return;
    final cries = _pokemon!['cries'];
    final url = cries?['latest'] ?? cries?['legacy'];
    if (url == null) return;
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo reproducir el sonido: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Pokémon',
                      hintText: 'Ej: pikachu',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.catching_pokemon),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _fetchPokemon(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _fetchPokemon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)))
                : _pokemon == null
                ? const Center(child: Text('Busca un Pokémon para comenzar'))
                : _buildPokemonCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonCard() {
    final p = _pokemon!;
    final sprites = p['sprites'];
    final imageUrl = sprites?['other']?['official-artwork']?['front_default']
        ?? sprites?['front_default'];
    final abilities = (p['abilities'] as List)
        .map((a) => a['ability']['name'].toString().toUpperCase())
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  p['name'].toString().toUpperCase(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (imageUrl != null)
                  Image.network(imageUrl, height: 200, fit: BoxFit.contain),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Chip(
                      label: Text('Exp. Base: ${p['base_experience']}'),
                      backgroundColor: Colors.red.shade100,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('Altura: ${p['height']}'),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ],
                ),
                const Divider(height: 30),
                const Text('Habilidades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...abilities.map((a) => Chip(
                  label: Text(a),
                  avatar: const Icon(Icons.flash_on, size: 18, color: Colors.amber),
                )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _playSound,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Reproducir sonido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}