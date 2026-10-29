// ============================================================
// VISTA 5 — Clima en República Dominicana (Santo Domingo) HOY
// API gratuita y SIN llave (API key): Open-Meteo
// https://api.open-meteo.com/v1/forecast?latitude=18.4861&longitude=-69.9312
//   &current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m
//   &daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max
//   &timezone=America/Santo_Domingo&forecast_days=1
// "forecast_days=1" = solo el pronóstico del día en que se abre la app.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/estados.dart';

class ClimaScreen extends StatefulWidget {
  const ClimaScreen({super.key});

  @override
  State<ClimaScreen> createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _datos;

  @override
  void initState() {
    super.initState();
    _cargarClima();
  }

  Future<void> _cargarClima() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '18.4861',     // Coordenadas de Santo Domingo
        'longitude': '-69.9312',
        'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'America/Santo_Domingo',
        'forecast_days': '1',
      });
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        setState(() => _datos = jsonDecode(respuesta.body));
      } else {
        setState(() => _error = 'Error del servidor (${respuesta.statusCode}).');
      }
    } catch (e) {
      setState(() => _error = 'No hay conexión a internet.');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // La API devuelve un número (código WMO). Lo traducimos a texto + emoji.
  // Usamos un "switch expression" de Dart 3.
  (String, String) _describir(int codigo) => switch (codigo) {
        0 => ('Despejado', '☀️'),
        1 || 2 => ('Parcialmente nublado', '⛅'),
        3 => ('Nublado', '☁️'),
        45 || 48 => ('Neblina', '🌫️'),
        >= 51 && <= 57 => ('Llovizna', '🌦️'),
        >= 61 && <= 67 => ('Lluvia', '🌧️'),
        >= 80 && <= 82 => ('Aguaceros', '🌧️'),
        >= 95 => ('Tormenta eléctrica', '⛈️'),
        _ => ('Variable', '🌤️'), // "_" = cualquier otro caso
      };

  String _fechaDeHoy() {
    const dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
      'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final hoy = DateTime.now();
    // weekday va de 1 (lunes) a 7 (domingo); las listas empiezan en 0, por eso "-1".
    return '${dias[hoy.weekday - 1]}, ${hoy.day} de ${meses[hoy.month - 1]} de ${hoy.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima en RD')),
      body: _cargando
          ? const Cargando(mensaje: 'Consultando el clima...')
          : _error != null
              ? MensajeError(mensaje: _error!, alReintentar: _cargarClima)
              : _construirClima(),
    );
  }

  Widget _construirClima() {
    final actual = _datos!['current'];
    final diario = _datos!['daily'];
    // Los datos "daily" vienen en listas: [0] es el día de hoy.
    final codigo = (diario['weather_code'][0] as num).toInt();
    final (descripcion, emoji) = _describir(codigo); // Desestructurar el "record"

    return RefreshIndicator(
      onRefresh: _cargarClima, // Deslizar hacia abajo para actualizar
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Tarjeta principal con degradado de color.
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text('Santo Domingo, República Dominicana',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Text(_fechaDeHoy(), style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Text(emoji, style: const TextStyle(fontSize: 72)),
                Text('${actual['temperature_2m']} °C',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                Text(descripcion, style: const TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.arrow_upward, color: Colors.red),
                  title: const Text('Máxima de hoy'),
                  trailing: Text('${diario['temperature_2m_max'][0]} °C'),
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_downward, color: Colors.blue),
                  title: const Text('Mínima de hoy'),
                  trailing: Text('${diario['temperature_2m_min'][0]} °C'),
                ),
                ListTile(
                  leading: const Icon(Icons.umbrella),
                  title: const Text('Probabilidad de lluvia'),
                  trailing: Text('${diario['precipitation_probability_max'][0] ?? 0} %'),
                ),
                ListTile(
                  leading: const Icon(Icons.water_drop),
                  title: const Text('Humedad'),
                  trailing: Text('${actual['relative_humidity_2m']} %'),
                ),
                ListTile(
                  leading: const Icon(Icons.air),
                  title: const Text('Viento'),
                  trailing: Text('${actual['wind_speed_10m']} km/h'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
