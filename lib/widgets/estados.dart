// ============================================================
// estados.dart — Widgets reutilizables para los 3 estados
// típicos de una pantalla que consume una API:
//   1) Cargando   2) Error   3) Datos listos
// Los ponemos aquí para no repetir el mismo código en cada vista.
// ============================================================

import 'package:flutter/material.dart';

// Rueda girando mientras esperamos la respuesta de la API.
class Cargando extends StatelessWidget {
  final String mensaje;
  const Cargando({super.key, this.mensaje = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // La columna ocupa solo lo necesario
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12), // Espacio vertical de 12 píxeles
          Text(mensaje),
        ],
      ),
    );
  }
}

// Mensaje de error con un botón para volver a intentar.
class MensajeError extends StatelessWidget {
  final String mensaje;
  final VoidCallback? alReintentar; // Función que se ejecuta al tocar "Reintentar"

  const MensajeError({super.key, required this.mensaje, this.alReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            // "if" dentro de una lista: el botón solo aparece si hay función.
            if (alReintentar != null) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: alReintentar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
