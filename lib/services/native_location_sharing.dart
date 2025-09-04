import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class NativeLocationSharing {
  static const MethodChannel _channel = MethodChannel(
    'native_location_sharing',
  );

  // Compartir ubicación en tiempo real usando la API nativa de Android
  static Future<bool> shareLiveLocation({
    required List<String> phoneNumbers,
    required String threatDescription,
    required int durationMinutes,
  }) async {
    try {
      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
        '📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}',
      );

      // Preparar datos para la API nativa
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'phoneNumbers': phoneNumbers,
        'threatDescription': threatDescription,
        'durationMinutes': durationMinutes,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Llamar al método nativo
      final result = await _channel.invokeMethod(
        'shareLiveLocation',
        locationData,
      );

      if (result == true) {
        debugPrint('✅ Ubicación en tiempo real compartida exitosamente');
        return true;
      } else {
        debugPrint('❌ Error compartiendo ubicación en tiempo real');
        return false;
      }
    } catch (e) {
      debugPrint('Error en shareLiveLocation: $e');
      return false;
    }
  }

  // Detener compartir ubicación en tiempo real
  static Future<bool> stopLiveLocationSharing() async {
    try {
      final result = await _channel.invokeMethod('stopLiveLocationSharing');
      debugPrint('🛑 Compartir ubicación detenido: $result');
      return result == true;
    } catch (e) {
      debugPrint('Error deteniendo ubicación: $e');
      return false;
    }
  }

  // Verificar si se está compartiendo ubicación
  static Future<bool> isSharingLocation() async {
    try {
      final result = await _channel.invokeMethod('isSharingLocation');
      return result == true;
    } catch (e) {
      debugPrint('Error verificando estado: $e');
      return false;
    }
  }

  // Obtener información de la ubicación compartida
  static Future<Map<String, dynamic>?> getSharingInfo() async {
    try {
      final result = await _channel.invokeMethod('getSharingInfo');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('Error obteniendo información: $e');
      return null;
    }
  }
}
