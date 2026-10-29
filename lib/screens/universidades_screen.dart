// ============================================================
// VISTA 4 — Universidades de un país (nombre del país en inglés)
// API: https://adamix.net/proxy.php?country=Dominican+Republic
// Devuelve una LISTA de universidades, cada una así:
// { "name": "Instituto Tecnológico de Las Américas",
//   "domains": ["itla.edu.do"],
//   "web_pages": ["https://www.itla.edu.do/"], ... }
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UniversidadesScreen extends StatefulWidget {
  const UniversidadesScreen({super.key});

  @override
  State<UniversidadesScreen> createState() => _UniversidadesScreenState();
}

class _UniversidadesScreenState extends State<UniversidadesScreen> {
  final _paisCtrl = TextEditingController(text: 'Dominican Republic');
  bool _cargando = false;
  String? _error;
  List<dynamic> _universidades = []; // Lista vacía al inicio

  Future<void> _buscar() async {
    final pais = _paisCtrl.text.trim();
    if (pais.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _cargando = true;
      _error = null;
      _universidades = [];
    });

    try {
      // Uri.https convierte los espacios en "+": Dominican+Republic
      final url = Uri.https('adamix.net', '/proxy.php', {'country': pais});
      final respuesta = await http.get(url);
      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        setState(() {
          _universidades = datos is List ? datos : [];
          if (_universidades.isEmpty) {
            _error = 'No se encontraron universidades para "$pais".\n'
                'Recuerda escribir el país en inglés (Ej: Mexico, Spain, Colombia).';
          }
        });
      } else {
        setState(() => _error = 'Error del servidor (${respuesta.statusCode}).');
      }
    } catch (e) {
      setState(() => _error = 'No hay conexión a internet.');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // Algunos campos vienen como lista ["a","b"]; tomamos el primero.
  String _primero(dynamic valor) {
    if (valor is List && valor.isNotEmpty) return valor.first.toString();
    if (valor is String) return valor;
    return '—';
  }

  // Abre la página web en el navegador del teléfono.
  Future<void> _abrirWeb(String link) async {
    final ok = await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace')));
    }
  }

  @override
  void dispose() {
    _paisCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universidades')),
      body: Column(
        children: [
          // ---------- Buscador ----------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Expanded: el TextField ocupa todo el espacio que sobra.
                Expanded(
                  child: TextField(
                    controller: _paisCtrl,
                    decoration: const InputDecoration(
                      labelText: 'País (en inglés)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.public),
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
          ),
          if (_universidades.isNotEmpty)
            Text('${_universidades.length} universidades encontradas'),

          // ---------- Resultados ----------
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center)))
                    // ListView.builder crea solo las filas visibles (eficiente).
                    : ListView.builder(
                        itemCount: _universidades.length,
                        itemBuilder: (context, i) {
                          final u = _universidades[i];
                          final nombre = u['name'] ?? 'Sin nombre';
                          final dominio = _primero(u['domains']);
                          final web = _primero(u['web_pages']);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nombre,
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    const Icon(Icons.dns, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text('Dominio: $dominio')),
                                  ]),
                                  // TextButton con el link a la página web.
                                  if (web != '—')
                                    TextButton.icon(
                                      onPressed: () => _abrirWeb(web),
                                      icon: const Icon(Icons.open_in_new, size: 16),
                                      label: Text(web, overflow: TextOverflow.ellipsis),
                                    ),
                                ],
                              ),
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
