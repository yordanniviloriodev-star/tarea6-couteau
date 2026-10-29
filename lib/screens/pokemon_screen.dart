// ============================================================
// VISTA 6 — Buscar un Pokémon
// API: https://pokeapi.co/api/v2/pokemon/pikachu
// Campos que usamos de la respuesta:
//   sprites.other["official-artwork"].front_default -> foto
//   base_experience                                 -> experiencia base
//   abilities[i].ability.name                       -> habilidades
//   cries.latest                                    -> sonido (.ogg)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart'; // Reproductor de audio

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final _nombreCtrl = TextEditingController(text: 'pikachu');
  final AudioPlayer _reproductor = AudioPlayer(); // Objeto que suena el audio

  bool _cargando = false;
  String? _error;
  Map<String, dynamic>? _pokemon;

  Future<void> _buscar() async {
    // La API exige el nombre en minúsculas y sin espacios al inicio/final.
    final nombre = _nombreCtrl.text.trim().toLowerCase();
    if (nombre.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _cargando = true;
      _error = null;
      _pokemon = null;
    });

    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$nombre');
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        setState(() => _pokemon = jsonDecode(respuesta.body));
      } else if (respuesta.statusCode == 404) {
        // 404 = "no encontrado": ese Pokémon no existe.
        setState(() => _error = 'No existe un Pokémon llamado "$nombre".');
      } else {
        setState(() => _error = 'Error del servidor (${respuesta.statusCode}).');
      }
    } catch (e) {
      setState(() => _error = 'No hay conexión a internet.');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _reproducirSonido(String urlSonido) async {
    await _reproductor.stop();                    // Detiene si ya estaba sonando
    await _reproductor.play(UrlSource(urlSonido)); // Reproduce desde internet
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _reproductor.dispose(); // Muy importante: liberar el reproductor
    super.dispose();
  }

  // Convierte "static-ability" en "Static ability".
  String _bonito(String texto) {
    final limpio = texto.replaceAll('-', ' ');
    return limpio[0].toUpperCase() + limpio.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Pokémon',
                    hintText: 'Ej: pikachu, charmander',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.catching_pokemon),
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _cargando ? null : _buscar,
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_cargando) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          if (_pokemon != null) _construirPokemon(),
        ],
      ),
    );
  }

  Widget _construirPokemon() {
    final p = _pokemon!;
    // "?." y "??" evitan errores si algún campo viene vacío (null).
    final String? foto = p['sprites']?['other']?['official-artwork']?['front_default'] ??
        p['sprites']?['front_default'];
    final experiencia = p['base_experience'] ?? 'N/D';
    final List habilidades = p['abilities'] ?? [];
    final String? sonido = p['cries']?['latest'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_bonito(p['name']),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            if (foto != null) Image.network(foto, height: 220),
            const SizedBox(height: 8),
            Chip(
              avatar: const Icon(Icons.star, color: Colors.amber),
              label: Text('Experiencia base: $experiencia'),
            ),
            const SizedBox(height: 12),
            const Text('Habilidades', style: TextStyle(fontWeight: FontWeight.bold)),
            // Wrap acomoda los chips en varias líneas si no caben en una.
            Wrap(
              spacing: 8,
              children: habilidades
                  // <Widget> le dice a Dart que la lista es de widgets
                  .map<Widget>((h) => Chip(label: Text(_bonito(h['ability']['name']))))
                  .toList(),
            ),
            const SizedBox(height: 16),
            if (sonido != null)
              FilledButton.icon(
                onPressed: () => _reproducirSonido(sonido),
                icon: const Icon(Icons.volume_up),
                label: const Text('Escuchar sonido'),
              ),
          ],
        ),
      ),
    );
  }
}
