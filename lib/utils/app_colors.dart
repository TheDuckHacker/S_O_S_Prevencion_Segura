import 'package:flutter/material.dart';

class AppColors {
  // Colores principales - Degradado azul a morado (tranquilidad y confianza)
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryPurple = Color(0xFF9B59B6);
  static const Color secondaryBlue = Color(0xFF5DADE2);
  static const Color lightBlue = Color(0xFF85C1E9);

  // Botón SOS - Rojo a naranja (urgencia y alerta)
  static const Color sosRed = Color(0xFFE74C3C);
  static const Color sosOrange = Color(0xFFE67E22);
  static const Color dangerRed = Color(0xFFC0392B);

  // Botones secundarios - Verde a azul claro (acciones seguras, prevención)
  static const Color safeGreen = Color(0xFF27AE60);
  static const Color lightGreen = Color(0xFF58D68D);
  static const Color infoBlue = Color(0xFF3498DB);

  // Colores de fondo y texto
  static const Color backgroundColor = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFF16213E);
  static const Color surfaceColor = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8B8);

  // Degradados
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryPurple],
  );

  static const LinearGradient sosGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sosRed, sosOrange],
  );

  static const LinearGradient safeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [safeGreen, infoBlue],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackground, surfaceColor],
  );
}
