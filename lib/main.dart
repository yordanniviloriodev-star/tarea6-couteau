// ============================================================
// main.dart — Punto de entrada de la app "Couteau"
// "Couteau" significa "navaja" en francés: una app con muchas
// herramientas pequeñas, como una navaja suiza.
// ============================================================

import 'package:flutter/material.dart'; // Widgets de Material Design
import 'screens/inicio_screen.dart';    // Vista 1: la caja de herramientas

// main() es lo PRIMERO que se ejecuta al abrir la app.
void main() {
  // runApp recibe el widget raíz (el "tronco" del árbol de widgets).
  runApp(const CouteauApp());
}

// StatelessWidget = widget que no cambia por sí solo (no tiene estado).
class CouteauApp extends StatelessWidget {
  const CouteauApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp configura el tema, el título y la pantalla inicial.
    return MaterialApp(
      title: 'Couteau',
      debugShowCheckedModeBanner: false, // Quita la etiqueta "DEBUG"
      theme: ThemeData(
        // Color base del que Flutter genera toda la paleta de la app.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC62828)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const InicioScreen(), // Primera pantalla que se muestra
    );
  }
}
