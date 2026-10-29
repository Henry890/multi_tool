import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _gender;
  double? _probability;
  int? _count;
  bool _loading = false;
  String? _error;
  bool _hasResult = false;

  Future<void> _predictGender() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Por favor, ingresa un nombre');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _hasResult = false;
    });

    try {
      final response = await http
          .get(Uri.parse('https://api.genderize.io/?name=$name'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _gender = data['gender'];
          _probability = (data['probability'] as num?)?.toDouble();
          _count = data['count'];
          _hasResult = true;
        });
      } else {
        setState(() => _error = 'Error al consultar el servidor');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _gender == 'male';
    Color bgColor = Colors.white;
    if (_hasResult) {
      if (_gender == null) {
        bgColor = Colors.grey.shade200;
      } else {
        bgColor = isMale ? Colors.blue.shade100 : Colors.pink.shade100;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predecir Género'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la persona',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _nameController.clear();
                    setState(() {
                      _hasResult = false;
                      _error = null;
                    });
                  },
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _predictGender(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _predictGender,
                icon: const Icon(Icons.search),
                label: Text(_loading ? 'Consultando...' : 'Predecir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_loading)
              const CircularProgressIndicator(color: Colors.pink)
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16))
            else if (_hasResult)
                Expanded(child: _buildResult(isMale)),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(bool isMale) {
    if (_gender == null) {
      return const Center(
        child: Text(
          'No se pudo determinar el género para este nombre.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Center(
      child: Card(
        color: isMale ? Colors.blue.shade300 : Colors.pink.shade300,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMale ? Icons.male : Icons.female,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                _nameController.text.trim(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isMale ? 'MASCULINO' : 'FEMENINO',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Probabilidad: ${((_probability ?? 0) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(
                'Muestras: ${_count ?? 0}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}