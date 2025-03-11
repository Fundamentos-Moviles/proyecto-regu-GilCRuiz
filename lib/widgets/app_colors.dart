import 'package:flutter/material.dart';

class AppColors {
  
  // Colores primarios
  static const Color primaryColor = Color(0xFF000000); // Negro usado en ElevatedButtonTheme (backgroundColor) y borde de InputDecorationTheme (enabledBorder) en main.dart

  // Colores de fondo (sugerido, ajustable con otras páginas)
  static const Color scaffoldBackground = Color(0xFFFAFAFA); // Gris claro por defecto para Scaffold, puede cambiar según otras páginas

  // Colores de bordes (sugerido para focusedBorder)
  static const Color focusedBorder = Color.fromARGB(255, 255, 255, 255); // Morado sugerido para borde enfocado en InputDecorationTheme, ajustable

  // Colores de indicadores (sugerido para CircularProgressIndicator)
  static const Color loadingIndicator = Color.fromARGB(255, 255, 255, 255); // Morado sugerido para CircularProgressIndicator en main.dart

  // Método para convertir hex a Color (opcional, si prefieres usar hex como string)
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}