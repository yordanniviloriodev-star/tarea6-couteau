// ============================================================
// VISTA 2 — Predecir el género a partir de un nombre
// API: https://api.genderize.io/?name=irma
// Respuesta de ejemplo:
//   {"count":..., "name":"irma", "gender":"female", "probability":0.98}
// Masculino -> pantalla AZUL | Femenino -> pantalla ROSA
// ============================================================

import 'dart:convert';                     // jsonDecode: texto JSON -> Map de Dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;   // Para hacer peticiones HTTP

// StatefulWidget = widget que SÍ cambia (tiene estado: cargando, resultado...).
class GeneroScreen extends StatefulWidget {
  const GeneroScreen({super.key});

  @override
  State<GeneroScreen> createState() => _GeneroScreenState();
}

class _GeneroScreenState extends State<GeneroScreen> {
  // Controlador: nos deja leer lo que el usuario escribe en el TextField.
  final TextEditingController _nombreCtrl = TextEditingController();

  // Variables de estado (cuando cambian, la pantalla se redibuja).
  bool _cargando = false;
  String? _genero;        // "male", "female" o null
  double? _probabilidad;  // de 0.0 a 1.0
  String? _error;

  // Función asíncrona: espera la respuesta de internet sin congelar la app.
  Future<void> _predecir() async {
    final nombre = _nombreCtrl.text.trim(); // trim() quita espacios extra
    if (nombre.isEmpty) {
      setState(() => _error = 'Escribe un nombre primero.');
      return;
    }

    FocusScope.of(context).unfocus(); // Cierra el teclado

    setState(() {
      _cargando = true;
      _error = null;
      _genero = null;
    });

    try {
      // Uri.https arma la URL y codifica el nombre (espacios, tildes, etc.)
      final url = Uri.https('api.genderize.io', '/', {'name': nombre});
      final respuesta = await http.get(url); // await = "espera aquí la respuesta"

      if (respuesta.statusCode == 200) {
        // 200 = todo salió bien. Convertimos el texto JSON a un Map.
        final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
        setState(() {
          _genero = datos['gender'];                                // puede venir null
          _probabilidad = (datos['probability'] as num?)?.toDouble();
          if (_genero == null) _error = 'No se pudo predecir el género de "$nombre".';
        });
      } else if (respuesta.statusCode == 429) {
        // 429 = demasiadas peticiones (la API gratis tiene límite diario).
        setState(() => _error = 'Se alcanzó el límite diario de la API. Intenta mañana.');
      } else {
        setState(() => _error = 'Error del servidor (${respuesta.statusCode}).');
      }
    } catch (e) {
      // catch atrapa errores como "no hay internet".
      setState(() => _error = 'No hay conexión a internet.');
    } finally {
      // finally se ejecuta SIEMPRE, haya error o no.
      setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose(); // Liberar memoria al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Decidimos los colores según el resultado.
    final esHombre = _genero == 'male';
    final esMujer = _genero == 'female';
    final Color colorFondo = esHombre
        ? Colors.blue.shade100
        : esMujer
            ? Colors.pink.shade100
            : Colors.white;
    final Color colorFuerte = esHombre ? Colors.blue : Colors.pink;

    return Scaffold(
      appBar: AppBar(title: const Text('Predecir género')),
      // AnimatedContainer cambia el color de fondo con una animación suave.
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: colorFondo,
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre de la persona',
                hintText: 'Ej: Irma',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.person),
              ),
              onSubmitted: (_) => _predecir(), // Enter del teclado también busca
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              // Si está cargando, el botón se desactiva (onPressed: null).
              onPressed: _cargando ? null : _predecir,
              icon: const Icon(Icons.search),
              label: const Text('Predecir'),
            ),
            const SizedBox(height: 32),

            if (_cargando) const Center(child: CircularProgressIndicator()),

            if (_error != null)
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16)),

            // Resultado: solo se muestra si hay género.
            if (_genero != null)
              Column(
                children: [
                  Icon(esHombre ? Icons.male : Icons.female, size: 140, color: colorFuerte),
                  Text(
                    esHombre ? 'MASCULINO' : 'FEMENINO',
                    style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold, color: colorFuerte),
                  ),
                  const SizedBox(height: 8),
                  if (_probabilidad != null)
                    // Convertimos 0.98 -> "98%"
                    Text('Probabilidad: ${(_probabilidad! * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 18)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
