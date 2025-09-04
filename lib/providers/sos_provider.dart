import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';
import '../services/whatsapp_service.dart';
import '../services/recording_service.dart';
import '../services/realtime_service.dart';
import '../services/realtime_whatsapp_service.dart';

class SosProvider extends ChangeNotifier {
  bool _isSosActive = false;
  bool _isRecording = false;
  String _currentLocation = '';
  String _threatDescription = '';
  List<String> _evidenceFiles = [];
  List<Map<String, dynamic>> _sosHistory = [];

  // Getters
  bool get isSosActive => _isSosActive;
  bool get isRecording => _isRecording;
  String get currentLocation => _currentLocation;
  String get threatDescription => _threatDescription;
  List<String> get evidenceFiles => _evidenceFiles;
  List<Map<String, dynamic>> get sosHistory => _sosHistory;

  SosProvider() {
    _loadSosHistory();
  }

  // Cargar historial de SOS desde SharedPreferences
  Future<void> _loadSosHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('sos_history') ?? '[]';
      final List<dynamic> history = json.decode(historyJson);
      _sosHistory = history.cast<Map<String, dynamic>>();
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando historial SOS: $e');
    }
  }

  // Guardar historial de SOS en SharedPreferences
  Future<void> _saveSosHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sos_history', json.encode(_sosHistory));
    } catch (e) {
      debugPrint('Error guardando historial SOS: $e');
    }
  }

  // Actualizar descripción de amenaza
  void updateThreatDescription(String newDescription) {
    _threatDescription = newDescription;

    // Actualizar el último registro en el historial si hay uno activo
    if (_sosHistory.isNotEmpty && _sosHistory.last['status'] == 'active') {
      _sosHistory.last['description'] = newDescription;
      _saveSosHistory();
    }

    notifyListeners();
  }

  // Activar SOS
  Future<void> activateSos() async {
    try {
      _isSosActive = true;
      _currentLocation = await _getCurrentLocation();

      // Crear registro de SOS
      final sosRecord = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'active',
        'description': _threatDescription,
        'location': _currentLocation,
        'evidenceFiles': List<String>.from(_evidenceFiles),
      };

      _sosHistory.add(sosRecord);
      await _saveSosHistory();

      // Mostrar notificación
      await NotificationService.showSosAlert(
        title: 'SOS Activado',
        body: 'Alerta de emergencia enviada a contactos',
        location: _currentLocation,
      );

      // Enviar por WhatsApp automáticamente
      await WhatsAppService.sendSosToAllContacts(
        message: _threatDescription,
        location: _currentLocation,
      );

      // Iniciar compartir ubicación en tiempo real por WhatsApp
      final emergencyContacts = await WhatsAppService.getEmergencyContacts();
      final phoneNumbers =
          emergencyContacts
              .where((contact) => contact['hasWhatsApp'] == true)
              .map((contact) => contact['phone'].toString())
              .toList();

      if (phoneNumbers.isNotEmpty) {
        await RealtimeWhatsAppService.startRealtimeLocationSharing(
          threatDescription: _threatDescription,
          additionalText: _threatDescription,
          phoneNumbers: phoneNumbers,
          durationMinutes: 60, // 1 hora de compartir ubicación
        );
      }

      // Enviar datos al servidor automáticamente
      await RealtimeService.sendEmergencyData(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        message: _threatDescription,
        location: _currentLocation,
        timestamp: DateTime.now().toIso8601String(),
      );

      // Enviar ubicación en tiempo real al servidor
      final locationParts = _currentLocation.split(',');
      if (locationParts.length >= 2) {
        await RealtimeService.sendLocationUpdate(
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          latitude: double.tryParse(locationParts[0]) ?? 0.0,
          longitude: double.tryParse(locationParts[1]) ?? 0.0,
          location: _currentLocation,
          timestamp: DateTime.now().toIso8601String(),
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error activando SOS: $e');
    }
  }

  // Desactivar SOS
  Future<void> deactivateSos() async {
    try {
      _isSosActive = false;

      // Actualizar el último registro en el historial
      if (_sosHistory.isNotEmpty && _sosHistory.last['status'] == 'active') {
        _sosHistory.last['status'] = 'resolved';
        _sosHistory.last['resolvedAt'] = DateTime.now().toIso8601String();
        await _saveSosHistory();
      }

      // Cancelar notificaciones
      await NotificationService.cancelRecordingNotification();

      // Detener compartir ubicación en tiempo real
      await RealtimeWhatsAppService.stopRealtimeLocationSharing();

      // Liberar recursos de la cámara
      await RecordingService.dispose();

      notifyListeners();
    } catch (e) {
      debugPrint('Error desactivando SOS: $e');
    }
  }

  // Iniciar grabación
  Future<void> startRecording() async {
    try {
      // Solo permitir grabación si SOS está activo
      if (!_isSosActive) {
        debugPrint('No se puede grabar sin activar SOS primero');
        return;
      }

      _isRecording = true;

      // Mostrar notificación de grabación
      await NotificationService.showRecordingStarted();

      // Iniciar grabación de video
      await RecordingService.startVideoRecording();

      notifyListeners();
    } catch (e) {
      debugPrint('Error iniciando grabación: $e');
    }
  }

  // Detener grabación
  Future<void> stopRecording() async {
    try {
      _isRecording = false;

      // Detener grabación de video
      final videoPath = await RecordingService.stopVideoRecording();
      if (videoPath != null) {
        _evidenceFiles.add(videoPath);

        // Enviar archivo de evidencia al servidor
        await RealtimeService.sendEvidenceFile(
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          filePath: videoPath,
          fileType: 'video',
          timestamp: DateTime.now().toIso8601String(),
        );

        // Enviar grabación por WhatsApp a contactos de emergencia
        await WhatsAppService.sendRecordingToAllContacts(
          filePath: videoPath,
          message: _threatDescription,
          location: _currentLocation,
        );
      }

      // Cancelar notificación de grabación
      await NotificationService.cancelRecordingNotification();

      notifyListeners();
    } catch (e) {
      debugPrint('Error deteniendo grabación: $e');
    }
  }

  // Obtener ubicación actual con máxima precisión
  Future<String> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation, // Máxima precisión
        timeLimit: const Duration(seconds: 30),
        forceAndroidLocationManager: false,
      );
      return '${position.latitude}, ${position.longitude} (Precisión: ${position.accuracy.toStringAsFixed(1)}m)';
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      return 'Ubicación no disponible';
    }
  }

  // Compartir ubicación en tiempo real por WhatsApp
  Future<void> shareLocationViaWhatsApp() async {
    try {
      if (_currentLocation.isEmpty) {
        _currentLocation = await _getCurrentLocation();
      }

      await WhatsAppService.sendSosToAllContacts(
        message: 'Compartiendo mi ubicación actual por seguridad',
        location: _currentLocation,
      );

      // Agregar al historial
      _sosHistory.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'location_share',
        'location': _currentLocation,
        'status': 'completed',
      });

      await _saveSosHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error compartiendo ubicación: $e');
    }
  }

  // Limpiar historial
  Future<void> clearHistory() async {
    try {
      _sosHistory.clear();
      await _saveSosHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error limpiando historial: $e');
    }
  }

  // Obtener estadísticas
  Map<String, dynamic> getStats() {
    final totalSos =
        _sosHistory.where((record) => record['status'] == 'resolved').length;
    final activeSos =
        _sosHistory.where((record) => record['status'] == 'active').length;
    final totalEvidence = _evidenceFiles.length;

    return {
      'totalSos': totalSos,
      'activeSos': activeSos,
      'totalEvidence': totalEvidence,
      'lastSos': _sosHistory.isNotEmpty ? _sosHistory.last['timestamp'] : null,
    };
  }

  // Exportar historial
  Future<String> exportHistory() async {
    try {
      return json.encode(_sosHistory);
    } catch (e) {
      debugPrint('Error exportando historial: $e');
      return '[]';
    }
  }

  // Importar historial
  Future<void> importHistory(String historyJson) async {
    try {
      final List<dynamic> history = json.decode(historyJson);
      _sosHistory = history.cast<Map<String, dynamic>>();
      await _saveSosHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error importando historial: $e');
    }
  }
}
