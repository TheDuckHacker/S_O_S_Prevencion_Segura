import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'whatsapp_service.dart';
import 'realtime_service.dart';

class AutoDetectionService {
  static const String _lastLocationKey = 'last_location';
  static const String _lastActivityKey = 'last_activity';
  static const String _autoDetectionEnabledKey = 'auto_detection_enabled';

  static bool _isMonitoring = false;
  static Position? _lastPosition;
  static DateTime? _lastActivityTime;

  // Habilitar/deshabilitar detección automática
  static Future<void> setAutoDetectionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDetectionEnabledKey, enabled);
  }

  static Future<bool> isAutoDetectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoDetectionEnabledKey) ?? false;
  }

  // Iniciar monitoreo automático
  static Future<void> startAutoMonitoring() async {
    if (_isMonitoring) return;

    final enabled = await isAutoDetectionEnabled();
    if (!enabled) return;

    _isMonitoring = true;
    debugPrint('Iniciando monitoreo automático de actividad sospechosa');

    // Monitorear cada 30 segundos
    _monitorActivity();
  }

  // Detener monitoreo automático
  static Future<void> stopAutoMonitoring() async {
    _isMonitoring = false;
    debugPrint('Deteniendo monitoreo automático');
  }

  // Monitorear actividad sospechosa
  static Future<void> _monitorActivity() async {
    while (_isMonitoring) {
      try {
        await _checkSuspiciousActivity();
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        debugPrint('Error en monitoreo automático: $e');
        await Future.delayed(const Duration(seconds: 60));
      }
    }
  }

  // Verificar actividad sospechosa
  static Future<void> _checkSuspiciousActivity() async {
    try {
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          currentPosition.latitude,
          currentPosition.longitude,
        );

        // Si se movió más de 100 metros en menos de 2 minutos = actividad sospechosa
        final timeDiff = DateTime.now().difference(
          _lastActivityTime ?? DateTime.now(),
        );

        if (distance > 100 && timeDiff.inMinutes < 2) {
          await _triggerSuspiciousActivityAlert(currentPosition);
        }
      }

      _lastPosition = currentPosition;
      _lastActivityTime = DateTime.now();

      // Guardar última ubicación
      await _saveLastLocation(currentPosition);
    } catch (e) {
      debugPrint('Error verificando actividad sospechosa: $e');
    }
  }

  // Activar alerta por actividad sospechosa
  static Future<void> _triggerSuspiciousActivityAlert(Position position) async {
    try {
      debugPrint('🚨 ACTIVIDAD SOSPECHOSA DETECTADA 🚨');

      final location =
          '${position.latitude}, ${position.longitude} (Precisión: ${position.accuracy.toStringAsFixed(1)}m)';
      final message =
          'ACTIVIDAD SOSPECHOSA DETECTADA - Movimiento inusual detectado automáticamente';

      // Enviar automáticamente a WhatsApp
      await WhatsAppService.sendSosToAllContacts(
        message: message,
        location: location,
      );

      // Enviar al servidor
      await RealtimeService.sendEmergencyData(
        userId: 'auto_detection_${DateTime.now().millisecondsSinceEpoch}',
        message: message,
        location: location,
        timestamp: DateTime.now().toIso8601String(),
      );

      debugPrint('Alerta de actividad sospechosa enviada automáticamente');
    } catch (e) {
      debugPrint('Error enviando alerta de actividad sospechosa: $e');
    }
  }

  // Guardar última ubicación
  static Future<void> _saveLastLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastLocationKey,
        '${position.latitude},${position.longitude}',
      );
      await prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error guardando última ubicación: $e');
    }
  }

  // Cargar última ubicación
  static Future<Position?> _loadLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationStr = prefs.getString(_lastLocationKey);
      final activityStr = prefs.getString(_lastActivityKey);

      if (locationStr != null && activityStr != null) {
        final parts = locationStr.split(',');
        if (parts.length == 2) {
          _lastPosition = Position(
            latitude: double.parse(parts[0]),
            longitude: double.parse(parts[1]),
            timestamp: DateTime.parse(activityStr),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
          _lastActivityTime = DateTime.parse(activityStr);
        }
      }
    } catch (e) {
      debugPrint('Error cargando última ubicación: $e');
    }

    return _lastPosition;
  }

  // Inicializar servicio
  static Future<void> initialize() async {
    await _loadLastLocation();
    final enabled = await isAutoDetectionEnabled();
    if (enabled) {
      await startAutoMonitoring();
    }
  }
}
