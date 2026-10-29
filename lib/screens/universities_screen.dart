import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  final TextEditingController _countryController = TextEditingController();
  List<dynamic> _universities = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  Future<void> _fetchUniversities() async {
    final country = _countryController.text.trim();
    if (country.isEmpty) {
      setState(() => _error = 'Por favor, ingresa un país en inglés');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
      _universities = [];
    });

    try {
      final encoded = Uri.encodeComponent(country);
      final url =
          'https://adamix.net/proxy.php?country=$encoded';
      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            _universities = data;
          });
        } else {
          setState(() => _error = 'Formato de respuesta inesperado');
        }
      } else {
        setState(() => _error = 'Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidades por País'),
        backgroundColor: Colors.green,
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
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'País (en inglés)',
                      hintText: 'Ej: Dominican Republic',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.public),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _fetchUniversities(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _fetchUniversities,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            )
          else if (_searched && _universities.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No se encontraron universidades para ese país.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _universities.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final uni = _universities[index];
                    final name = uni['name'] ?? 'Sin nombre';
                    final domains = (uni['domains'] as List?) ?? [];
                    final webPages = (uni['web_pages'] as List?) ?? [];
                    final domain =
                    domains.isNotEmpty ? domains.first : 'N/A';
                    final web =
                    webPages.isNotEmpty ? webPages.first : 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.school, color: Colors.white),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Dominio: $domain'),
                        childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Row(
                            children: [
                              const Icon(Icons.link, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText(
                                  web,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.language, size: 18),
                              const SizedBox(width: 8),
                              Text(domain),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}