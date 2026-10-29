import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic>? _weather;
  bool _loading = false;
  String? _error;


  static const double _lat = 18.4861;
  static const double _lon = -69.9312;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$_lat&longitude=$_lon'
          '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
          '&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max'
          '&timezone=America/Santo_Domingo';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _weather = data);
      } else {
        setState(() => _error = 'Error al obtener el clima');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Traduce el código WMO a descripción y emoji
  Map<String, dynamic> _weatherInfo(int code) {
    if (code == 0) return {'desc': 'Despejado', 'icon': Icons.wb_sunny, 'color': Colors.orange};
    if (code <= 3) return {'desc': 'Parcialmente nublado', 'icon': Icons.wb_cloudy, 'color': Colors.blueGrey};
    if (code <= 48) return {'desc': 'Niebla', 'icon': Icons.foggy, 'color': Colors.grey};
    if (code <= 57) return {'desc': 'Llovizna', 'icon': Icons.grain, 'color': Colors.lightBlue};
    if (code <= 67) return {'desc': 'Lluvia', 'icon': Icons.water_drop, 'color': Colors.blue};
    if (code <= 77) return {'desc': 'Nieve', 'icon': Icons.ac_unit, 'color': Colors.lightBlue};
    if (code <= 82) return {'desc': 'Chubascos', 'icon': Icons.thunderstorm, 'color': Colors.blueAccent};
    if (code <= 86) return {'desc': 'Nieve fuerte', 'icon': Icons.ac_unit, 'color': Colors.lightBlue};
    if (code >= 95) return {'desc': 'Tormenta eléctrica', 'icon': Icons.thunderstorm, 'color': Colors.deepPurple};
    return {'desc': 'Desconocido', 'icon': Icons.help, 'color': Colors.grey};
  }

  String _formatDate() {
    const meses = ['enero','febrero','marzo','abril','mayo','junio',
      'julio','agosto','septiembre','octubre','noviembre','diciembre'];
    const dias = ['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'];
    final now = DateTime.now();
    return '${dias[now.weekday - 1]}, ${now.day} de ${meses[now.month - 1]} de ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima en República Dominicana'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchWeather),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : _weather == null
          ? const Center(child: Text('Sin datos'))
          : _buildWeatherBody(),
    );
  }

  Widget _buildWeatherBody() {
    final current = _weather!['current'];
    final daily = _weather!['daily'];
    final code = current['weather_code'] as int;
    final info = _weatherInfo(code);

    return RefreshIndicator(
      onRefresh: _fetchWeather,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 6,
            color: info['color'] as Color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Santo Domingo, RD',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    _formatDate(),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Icon(info['icon'] as IconData, size: 100, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    '${current['temperature_2m']}°C',
                    style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    info['desc'] as String,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _infoChip(Icons.water_drop, 'Humedad', '${current['relative_humidity_2m']}%'),
                      _infoChip(Icons.air, 'Viento', '${current['wind_speed_10m']} km/h'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Pronóstico del día', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _forecastItem(Icons.arrow_upward, 'Máx', '${daily['temperature_2m_max'][0]}°C', Colors.red),
                  _forecastItem(Icons.arrow_downward, 'Mín', '${daily['temperature_2m_min'][0]}°C', Colors.blue),
                  _forecastItem(Icons.umbrella, 'Lluvia', '${daily['precipitation_probability_max'][0]}%', Colors.indigo),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fuente: Open-Meteo.com',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _forecastItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}