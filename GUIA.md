# Tarea 6 — Couteau 🧰 (Flutter)

**Estudiante:** Yordanni Vilorio Jiminian · **Matrícula:** 2019-7711
**Asignatura:** Introducción al Desarrollo de Aplicaciones Móviles (TDS-011) — ITLA

"Couteau" significa *navaja* en francés: una app con varias herramientas, como una navaja suiza.

---

## 1. ¿Qué hace cada vista y qué API usa?

| # | Vista | Archivo | API |
|---|-------|---------|-----|
| 1 | Caja de herramientas (inicio + menú) | `inicio_screen.dart` | — (imagen local) |
| 2 | Predecir género (azul / rosa) | `genero_screen.dart` | `https://api.genderize.io/?name=irma` |
| 3 | Persona aleatoria | `persona_screen.dart` | `https://randomuser.me/api/?results=1` |
| 4 | Universidades por país | `universidades_screen.dart` | `https://adamix.net/proxy.php?country=Dominican+Republic` |
| 5 | Clima de hoy en RD | `clima_screen.dart` | `https://api.open-meteo.com/v1/forecast?...` (gratis, sin API key) |
| 6 | Pokémon (foto, experiencia, habilidades, sonido) | `pokemon_screen.dart` | `https://pokeapi.co/api/v2/pokemon/pikachu` |
| 7 | Noticias de WordPress (logo + 3 noticias + Visitar) | `wordpress_screen.dart` | `https://wordpress.org/news/wp-json/wp/v2/posts?per_page=3` |
| 8 | Acerca de (foto + contacto) | `acerca_screen.dart` | — |

```
couteau/
├── pubspec.yaml               ← paquetes, assets y configuración del ícono
├── assets/images/
│   ├── caja_herramientas.png  ← foto de la vista 1
│   └── foto_perfil.jpg        ← ⚠️ REEMPLÁZALA por tu foto (ícono + "Acerca de")
└── lib/
    ├── main.dart              ← punto de entrada
    ├── widgets/estados.dart   ← widgets de "Cargando" y "Error" reutilizables
    └── screens/               ← una pantalla por archivo (las 8 vistas)
```

---

## 2. Cómo funciona (la idea que se repite en todas las vistas con API)

**Explicación sencilla:** la app le hace una *pregunta* a un servidor por internet (la URL),
el servidor responde con un *texto ordenado* (JSON), la app saca de ese texto lo que necesita
y lo pinta en pantalla. Mientras espera, muestra una ruedita; si falla, muestra un error.

**Explicación técnica:** cada pantalla es un `StatefulWidget` con 3 variables de estado
(`_cargando`, `_error`, `_datos`). El patrón es siempre:

```dart
Future<void> _cargar() async {
  setState(() => _cargando = true);                 // 1. Mostrar "cargando"
  try {
    final respuesta = await http.get(url);          // 2. Petición GET (asíncrona)
    if (respuesta.statusCode == 200) {              // 3. ¿El servidor respondió bien?
      final datos = jsonDecode(respuesta.body);     // 4. Texto JSON -> Map/List de Dart
      setState(() => _datos = datos);               // 5. Guardar y redibujar la pantalla
    }
  } catch (e) {
    setState(() => _error = 'Sin internet');        // 6. Manejar errores
  } finally {
    setState(() => _cargando = false);              // 7. Quitar el "cargando" siempre
  }
}
```

- `async/await`: la app **no se congela** mientras llega la respuesta.
- `setState()`: le avisa a Flutter "cambió un dato, vuelve a ejecutar `build()`".
- `statusCode`: 200 = OK, 404 = no encontrado (Pokémon que no existe), 429 = límite de la API.

Cada archivo tiene comentarios línea por línea explicando el qué y el porqué.

---

## 3. Paso a paso para correrla en Android Studio

### 3.1 Crear el proyecto y copiar el código
```bash
flutter create couteau
```
Luego **reemplaza** dentro de esa carpeta `pubspec.yaml` y la carpeta `lib/` por los de este ZIP,
y copia la carpeta `assets/`. (Borra `test/widget_test.dart`; ese test de ejemplo ya no aplica.)

### 3.2 Permiso de internet y abrir links (¡obligatorio!)
Abre `android/app/src/main/AndroidManifest.xml`:

1. **Antes** de `<application`, agrega:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
2. Cambia el nombre que se ve bajo el ícono: `android:label="Couteau"`.
3. Dentro del bloque `<queries>` que ya existe al final, agrega:
```xml
<intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
</intent>
<intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="mailto" />
</intent>
```
> Sin el permiso de INTERNET, el APK **instalado** no podrá cargar ninguna API
> (en modo debug a veces funciona y engaña; en release no).

### 3.3 Tu foto como ícono
1. Pon tu foto (cuadrada, ideal 1024×1024) en `assets/images/foto_perfil.jpg`
   reemplazando la imagen roja que dice "REEMPLAZA CON TU FOTO".
2. Ejecuta:
```bash
flutter pub get
dart run flutter_launcher_icons
```

### 3.4 Probar y generar el APK
```bash
flutter run                 # Probar en el emulador o tu teléfono
flutter build apk --release # Genera el APK
```
El APK queda en: `build/app/outputs/flutter-apk/app-release.apk`
Renómbralo a **`couteau.apk`**.

---

## 4. Subir a GitHub (código + APK)

1. En GitHub crea el repositorio **`tarea6-couteau`** (público) en tu cuenta `yordanniviloriodev-star`.
2. En la carpeta del proyecto:
```bash
git init
git add .
git commit -m "Tarea 6: app Couteau con 8 vistas"
git branch -M main
git remote add origin https://github.com/yordanniviloriodev-star/tarea6-couteau.git
git push -u origin main
```
3. Publica el APK como **Release**: en el repo → *Releases* → *Create a new release* →
   Tag: **`v1.0`** → arrastra `couteau.apk` → *Publish release*.

Con esos nombres exactos, los links del PDF y el QR funcionan:
- Código: `https://github.com/yordanniviloriodev-star/tarea6-couteau`
- APK: `https://github.com/yordanniviloriodev-star/tarea6-couteau/releases/download/v1.0/couteau.apk`

---

## 5. Texto sugerido para el foro de WordPress

> **Sitio:** WordPress News (blog oficial de WordPress) — https://wordpress.org/news
> **API de noticias:** https://wordpress.org/news/wp-json/wp/v2/posts?per_page=3
> **API del sitio (nombre y logo):** https://wordpress.org/news/wp-json/

Si otro compañero ya publicó ese sitio, cambia la constante `_sitio` en
`lib/screens/wordpress_screen.dart` por otra página WordPress (prueba primero
`TU_SITIO/wp-json/wp/v2/posts?per_page=3` en el navegador: si ves JSON, sirve).
