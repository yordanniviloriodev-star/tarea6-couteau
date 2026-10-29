// ============================================================
// VISTA 8 — Acerca de: mi foto y mis datos de contacto
// (para posibles oportunidades de trabajo)
// ============================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AcercaScreen extends StatelessWidget {
  const AcercaScreen({super.key});

  // Abre WhatsApp, el correo o GitHub según el tipo de link.
  // "mailto:" abre la app de correo; "https://wa.me/" abre WhatsApp.
  Future<void> _abrir(String link) async {
    await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ---------- Foto ----------
          Center(
            child: CircleAvatar(
              radius: 85,
              backgroundColor: colores.primary, // Borde de color
              child: const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/images/foto_perfil.jpg'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Yordanni Vilorio Jiminian',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Desarrollador de Software',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          const Text('Tecnólogo en Desarrollo de Software — ITLA · Matrícula 2019-7711',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),

          // ---------- Habilidades ----------
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Flutter')),
              Chip(label: Text('C# / ASP.NET Core')),
              Chip(label: Text('SQL Server')),
              Chip(label: Text('React')),
              Chip(label: Text('Git / GitHub')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Disponible para trabajos y proyectos freelance.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),

          // ---------- Contacto (cada fila se puede tocar) ----------
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.red),
                  title: const Text('Correo'),
                  subtitle: const Text('yordanni.vilorio.dev@gmail.com'),
                  onTap: () => _abrir('mailto:yordanni.vilorio.dev@gmail.com'),
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('WhatsApp'),
                  subtitle: const Text('829-264-2947'),
                  // wa.me necesita el número con código de país (1 = RD).
                  onTap: () => _abrir('https://wa.me/18292642947'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('GitHub'),
                  subtitle: const Text('github.com/yordanniviloriodev-star'),
                  onTap: () => _abrir('https://github.com/yordanniviloriodev-star'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
