// ============================================================
// VISTA 1 — Inicio: foto de la caja de herramientas + menú
// Desde aquí el usuario entra a cada herramienta de la app.
// ============================================================

import 'package:flutter/material.dart';
import 'genero_screen.dart';
import 'persona_screen.dart';
import 'universidades_screen.dart';
import 'clima_screen.dart';
import 'pokemon_screen.dart';
import 'wordpress_screen.dart';
import 'acerca_screen.dart';

// Clase pequeña que describe una herramienta del menú.
// Así guardamos título, ícono, color y la pantalla destino juntos.
class Herramienta {
  final String titulo;
  final IconData icono;
  final Color color;
  final Widget pantalla;

  const Herramienta(this.titulo, this.icono, this.color, this.pantalla);
}

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  // Lista con las 7 herramientas (vistas 2 a la 8).
  static final List<Herramienta> herramientas = [
    Herramienta('Predecir género', Icons.wc, Colors.indigo, const GeneroScreen()),
    Herramienta('Persona aleatoria', Icons.person_search, Colors.teal, const PersonaScreen()),
    Herramienta('Universidades', Icons.school, Colors.deepPurple, const UniversidadesScreen()),
    Herramienta('Clima en RD', Icons.wb_sunny, Colors.orange, const ClimaScreen()),
    Herramienta('Pokémon', Icons.catching_pokemon, Colors.red, const PokemonScreen()),
    Herramienta('Noticias WordPress', Icons.newspaper, Colors.blueGrey, const WordPressScreen()),
    Herramienta('Acerca de', Icons.badge, Colors.green, const AcercaScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold = estructura básica de una pantalla (barra superior + cuerpo).
    return Scaffold(
      appBar: AppBar(title: const Text('Couteau 🧰')),
      // ListView permite hacer scroll si el contenido no cabe.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Foto de la caja de herramientas ----------
          ClipRRect(
            borderRadius: BorderRadius.circular(16), // Esquinas redondeadas
            child: Image.asset(
              'assets/images/caja_herramientas.png', // Imagen local (va dentro del APK)
              height: 200,
              fit: BoxFit.cover, // Llena el espacio sin deformarse
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Una caja de herramientas en tu bolsillo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Elige una herramienta para comenzar',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // ---------- Cuadrícula con las herramientas ----------
          GridView.count(
            crossAxisCount: 2,          // 2 columnas
            shrinkWrap: true,           // Ocupa solo el alto necesario
            physics: const NeverScrollableScrollPhysics(), // El scroll lo hace el ListView
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            // .map transforma cada Herramienta en una tarjeta (Card).
            children: herramientas.map((h) {
              return Card(
                color: h.color.withAlpha(30), // Color suave (30 de 255 = casi transparente)
                child: InkWell(
                  // InkWell hace la tarjeta "tocable" con efecto de onda.
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navigator.push abre una nueva pantalla encima de esta.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => h.pantalla),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(h.icono, size: 40, color: h.color),
                      const SizedBox(height: 8),
                      Text(h.titulo, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
