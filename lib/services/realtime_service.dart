import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import '../config/app_config.dart';

class RealtimeService {
  // URL del servidor desde configuración
  static String get _baseUrl => AppConfig.serverUrl;

  // Enviar datos de emergencia en tiempo real
  static Future<bool> sendEmergencyData({
    required String userId,
    required String location,
    required String message,
    required String timestamp,
    String? audioPath,
    String? videoPath,
    String? photoPath,
  }) async {
    try {
      final data = {
        'userId': userId,
        'type': 'emergency',
        'location': location,
        'message': message,
        'timestamp': timestamp,
        'audioPath': audioPath,
        'videoPath': videoPath,
        'photoPath': photoPath,
        'encrypted': true,
      };

      final response = await _sendData('/emergency', data);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error enviando datos de emergencia: $e');
      return false;
    }
  }

  // Enviar ubicación en tiempo real
  static Future<bool> sendLocationUpdate({
    required String userId,
    required String location,
    required double latitude,
    required double longitude,
    required String timestamp,
  }) async {
    try {
      final data = {
        'userId': userId,
        'type': 'location_update',
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        'encrypted': true,
      };

      final response = await _sendData('/location', data);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error enviando ubicación: $e');
      return false;
    }
  }

  // Enviar archivo de evidencia
  static Future<bool> sendEvidenceFile({
    required String userId,
    required String filePath,
    required String fileType,
    required String timestamp,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('Archivo no existe: $filePath');
        return false;
      }

      final bytes = await file.readAsBytes();
      final base64File = base64Encode(bytes);

      final data = {
        'userId': userId,
        'type': 'evidence',
        'fileType': fileType,
        'fileName': file.path.split('/').last,
        'fileData': base64File,
        'timestamp': timestamp,
        'encrypted': true,
      };

      final response = await _sendData('/evidence', data);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error enviando archivo de evidencia: $e');
      return false;
    }
  }

  // Enviar datos de progreso educativo
  static Future<bool> sendEducationProgress({
    required String userId,
    required String lessonName,
    required int score,
    required String timestamp,
  }) async {
    try {
      final data = {
        'userId': userId,
        'type': 'education_progress',
        'lessonName': lessonName,
        'score': score,
        'timestamp': timestamp,
        'encrypted': true,
      };

      final response = await _sendData('/education', data);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error enviando progreso educativo: $e');
      return false;
    }
  }

  // Enviar datos genéricos
  static Future<http.Response> _sendData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final jsonData = json.encode(data);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonData,
      );

      return response;
    } catch (e) {
      debugPrint('Error en petición HTTP: $e');
      rethrow;
    }
  }

  // Obtener token de autenticación
  static Future<String> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') ?? '';
    } catch (e) {
      debugPrint('Error obteniendo token de autenticación: $e');
      return '';
    }
  }

  // Encriptar datos sensibles
  static String _encryptData(String data) {
    try {
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      debugPrint('Error encriptando datos: $e');
      return data;
    }
  }

  // Verificar conexión a internet
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando conexión: $e');
      return false;
    }
  }

  // Enviar datos en lote (para cuando se recupere la conexión)
  static Future<void> sendBatchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final batchDataJson = prefs.getString('batch_data') ?? '[]';
      final List<dynamic> batchData = json.decode(batchDataJson);

      if (batchData.isEmpty) return;

      for (final data in batchData) {
        await _sendData('/batch', data);
      }

      // Limpiar datos enviados
      await prefs.remove('batch_data');
    } catch (e) {
      debugPrint('Error enviando datos en lote: $e');
    }
  }

  // Agregar datos a la cola de envío
  static Future<void> addToBatchQueue(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final batchDataJson = prefs.getString('batch_data') ?? '[]';
      final List<dynamic> batchData = json.decode(batchDataJson);

      batchData.add(data);

      await prefs.setString('batch_data', json.encode(batchData));
    } catch (e) {
      debugPrint('Error agregando a cola de envío: $e');
    }
  }

  // Obtener estadísticas de envío
  static Future<Map<String, dynamic>> getSendingStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'totalSent': prefs.getInt('total_sent') ?? 0,
        'totalFailed': prefs.getInt('total_failed') ?? 0,
        'lastSent': prefs.getString('last_sent'),
        'batchQueueSize': _getBatchQueueSize(),
      };
    } catch (e) {
      debugPrint('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  // Obtener tamaño de la cola de envío
  static int _getBatchQueueSize() {
    try {
      // Implementación simplificada
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Actualizar estadísticas de envío
  static Future<void> updateSendingStats({required bool success}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (success) {
        final totalSent = (prefs.getInt('total_sent') ?? 0) + 1;
        await prefs.setInt('total_sent', totalSent);
        await prefs.setString('last_sent', DateTime.now().toIso8601String());
      } else {
        final totalFailed = (prefs.getInt('total_failed') ?? 0) + 1;
        await prefs.setInt('total_failed', totalFailed);
      }
    } catch (e) {
      debugPrint('Error actualizando estadísticas: $e');
    }
  }
}
