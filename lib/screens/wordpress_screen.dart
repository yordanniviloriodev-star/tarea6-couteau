// ============================================================
// VISTA 7 — Últimas 3 noticias de una página hecha con WordPress
// Todo sitio WordPress trae una API REST pública en /wp-json
//   Info del sitio (nombre, logo):  {SITIO}/wp-json/
//   Últimas 3 noticias:             {SITIO}/wp-json/wp/v2/posts?per_page=3
// Sitio elegido: WordPress News (el blog oficial de WordPress).
// Si en el foro otro compañero ya usó este sitio, solo cambia la
// constante _sitio por otra página WordPress y listo.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../widgets/estados.dart';

// "const" a nivel de archivo: valores fijos que usa esta pantalla.
const String _sitio = 'https://wordpress.org/news';
const String _logoRespaldo = 'https://s.w.org/images/wmark.png';

class WordPressScreen extends StatefulWidget {
  const WordPressScreen({super.key});

  @override
  State<WordPressScreen> createState() => _WordPressScreenState();
}

class _WordPressScreenState extends State<WordPressScreen> {
  bool _cargando = true;
  String? _error;
  String _nombreSitio = 'WordPress News';
  String _logo = _logoRespaldo;
  List<dynamic> _noticias = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      // Future.wait lanza las 2 peticiones AL MISMO TIEMPO (más rápido)
      // y espera a que ambas terminen.
      final respuestas = await Future.wait([
        http.get(Uri.parse('$_sitio/wp-json/')),
        http.get(Uri.parse('$_sitio/wp-json/wp/v2/posts?per_page=3&_fields=title,excerpt,link,date')),
      ]);
      final info = respuestas[0];
      final posts = respuestas[1];

      if (posts.statusCode != 200) {
        throw Exception('Error ${posts.statusCode}');
      }

      setState(() {
        _noticias = jsonDecode(posts.body);
        // La info del sitio es opcional: si falla, usamos el logo de respaldo.
        if (info.statusCode == 200) {
          final datosSitio = jsonDecode(info.body);
          _nombreSitio = _limpiarHtml(datosSitio['name'] ?? _nombreSitio);
          final icono = datosSitio['site_icon_url'];
          if (icono is String && icono.isNotEmpty) _logo = icono;
        }
      });
    } catch (e) {
      setState(() => _error = 'No se pudieron cargar las noticias.');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // WordPress devuelve el título y el resumen con etiquetas HTML
  // (<p>, <a>...) y códigos como &#8217; ( ’ ). Aquí los limpiamos.
  String _limpiarHtml(String html) {
    var texto = html.replaceAll(RegExp(r'<[^>]*>'), ''); // Quita <etiquetas>
    // Convierte &#8217; -> ’  (códigos numéricos)
    texto = texto.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (m) => String.fromCharCode(int.parse(m.group(1)!)),
    );
    texto = texto
        .replaceAll('[&hellip;]', '…') // Primero el caso con corchetes
        .replaceAll('[…]', '…')
        .replaceAll('&hellip;', '…')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&');     // &amp; al final para no romper los demás
    return texto.trim();
  }

  // "2026-10-20T10:15:00" -> "20/10/2026"
  String _fecha(String iso) {
    final f = DateTime.tryParse(iso);
    if (f == null) return '';
    return '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';
  }

  Future<void> _visitar(String link) async {
    await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Noticias WordPress')),
      body: _cargando
          ? const Cargando(mensaje: 'Cargando noticias...')
          : _error != null
              ? MensajeError(mensaje: _error!, alReintentar: _cargar)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ---------- Logo del sitio ----------
                    Center(
                      child: Image.network(
                        _logo,
                        height: 90,
                        // Si la imagen falla, mostramos un ícono en su lugar.
                        errorBuilder: (_, __, ___) => const Icon(Icons.language, size: 90),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_nombreSitio,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const Text(_sitio, textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),

                    // ---------- Las 3 noticias ----------
                    // "for" dentro de la lista de children crea una Card por noticia.
                    for (final n in _noticias)
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_fecha(n['date'] ?? ''),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(_limpiarHtml(n['title']['rendered']),
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(_limpiarHtml(n['excerpt']['rendered']),
                                  maxLines: 5, overflow: TextOverflow.ellipsis),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _visitar(n['link']),
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Visitar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
