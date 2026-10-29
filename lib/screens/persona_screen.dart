// ============================================================
// VISTA 3 — Persona aleatoria
// API: https://randomuser.me/api/?results=1
// Estructura (resumida) de la respuesta:
// { "results": [ {
//     "name":    { "first": "Ana", "last": "Pérez" },
//     "dob":     { "date": "1990-05-12T08:30:00.000Z", "age": 36 },
//     "picture": { "large": "https://...jpg" }
// } ] }
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/estados.dart';

class PersonaScreen extends StatefulWidget {
  const PersonaScreen({super.key});

  @override
  State<PersonaScreen> createState() => _PersonaScreenState();
}

class _PersonaScreenState extends State<PersonaScreen> {
  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _persona; // Guardará el objeto results[0]

  // initState se ejecuta UNA vez cuando se abre la pantalla.
  @override
  void initState() {
    super.initState();
    _cargarPersona(); // Apenas entra, pedimos una persona.
  }

  Future<void> _cargarPersona() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final url = Uri.parse('https://randomuser.me/api/?results=1');
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        // "results" es una LISTA; tomamos el primer elemento [0].
        setState(() => _persona = datos['results'][0]);
      } else {
        setState(() => _error = 'Error del servidor (${respuesta.statusCode}).');
      }
    } catch (e) {
      setState(() => _error = 'No hay conexión a internet.');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // Convierte "1990-05-12T08:30:00.000Z" en "12/05/1990".
  String _formatearFecha(String fechaIso) {
    final fecha = DateTime.parse(fechaIso);
    // padLeft(2, '0') convierte 5 en "05".
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Persona aleatoria')),
      body: _construirCuerpo(),
      // Botón flotante para pedir otra persona.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cargando ? null : _cargarPersona,
        icon: const Icon(Icons.shuffle),
        label: const Text('Otra persona'),
      ),
    );
  }

  // Separamos el cuerpo en una función para que build() se lea mejor.
  Widget _construirCuerpo() {
    if (_cargando) return const Cargando(mensaje: 'Buscando a alguien...');
    if (_error != null) return MensajeError(mensaje: _error!, alReintentar: _cargarPersona);

    final p = _persona!; // "!" = sabemos que aquí no es null
    final nombre = p['name']['first'];
    final apellido = p['name']['last'];
    final foto = p['picture']['large'];
    final fechaNac = _formatearFecha(p['dob']['date']);
    final edad = p['dob']['age'];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 80,
            backgroundImage: NetworkImage(foto), // Foto desde internet
          ),
        ),
        const SizedBox(height: 24),
        // Card con cada dato en una fila (ListTile).
        Card(
          child: Column(
            children: [
              ListTile(leading: const Icon(Icons.person), title: const Text('Nombre'), subtitle: Text(nombre)),
              ListTile(leading: const Icon(Icons.people), title: const Text('Apellido'), subtitle: Text(apellido)),
              ListTile(leading: const Icon(Icons.cake), title: const Text('Fecha de nacimiento'), subtitle: Text(fechaNac)),
              ListTile(leading: const Icon(Icons.hourglass_bottom), title: const Text('Edad'), subtitle: Text('$edad años')),
            ],
          ),
        ),
      ],
    );
  }
}
