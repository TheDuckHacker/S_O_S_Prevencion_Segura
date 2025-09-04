import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/whatsapp_service.dart';
import '../services/recording_service.dart';
import '../services/realtime_service.dart';

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

  // Actualizar descripción de amenaza
  void updateThreatDescription(String newDescription) {
    _threatDescription = newDescription;
    
    // Actualizar el último registro en el historial si hay uno activo
    if (_sosHistory.isNotEmpty && _sosHistory.last['status'] == 'active') {
      _sosHistory.last['description'] = newDescription;
    }
    
    notifyListeners();
  }

  // Compartir ubicación en tiempo real por WhatsApp
  Future<void> shareLocationViaWhatsApp() async {
    try {
      if (_currentLocation.isEmpty) {
        _currentLocation = await _getCurrentLocation();
      }

      await WhatsAppService.shareLocationToAllContacts(
        location: _currentLocation,
        message: 'Compartiendo mi ubicación actual por seguridad',
      );

      // Agregar al historial
      _sosHistory.add({
        'timestamp': DateTime.now().toIso8601String(),
        'description': 'Ubicación compartida manualmente',
        'location': _currentLocation,
        'status': 'location_shared',
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error compartiendo ubicación: $e');
    }
  }

  // Activar SOS
  Future<void> activateSos(String description) async {
    try {
      _isSosActive = true;
      _threatDescription = description;
      _currentLocation = await _getCurrentLocation();

      // Agregar a historial
      _sosHistory.add({
        'timestamp': DateTime.now().toIso8601String(),
        'description': description,
        'location': _currentLocation,
        'status': 'active',
      });

      // Enviar notificación de alerta SOS
      await NotificationService.showSosAlert(
        title: '🚨 ALERTA SOS ACTIVADA',
        body: 'Se ha activado una alerta de emergencia',
        location: _currentLocation,
      );

      // Enviar mensaje a todos los contactos de WhatsApp
      await WhatsAppService.sendSosToAllContacts(
        message: description,
        location: _currentLocation,
        timestamp: DateTime.now().toString(),
      );

      // Enviar datos en tiempo real al servidor
      await RealtimeService.sendEmergencyData(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        location: _currentLocation,
        message: description,
        timestamp: DateTime.now().toIso8601String(),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error activando SOS: $e');
    }
  }

  // Desactivar SOS
  void deactivateSos() {
    _isSosActive = false;
    _isRecording = false;

    // Actualizar último registro en historial
    if (_sosHistory.isNotEmpty) {
      _sosHistory.last['status'] = 'resolved';
      _sosHistory.last['resolvedAt'] = DateTime.now().toIso8601String();
    }

    notifyListeners();
  }

  // Iniciar grabación de evidencia
  Future<void> startRecording() async {
    try {
      _isRecording = true;

      // Mostrar notificación de grabación
      await NotificationService.showRecordingStarted();

      // Iniciar grabación de audio
      await RecordingService.startVideoRecording();

      notifyListeners();
    } catch (e) {
      debugPrint('Error iniciando grabación: $e');
    }
  }

  // Detener grabación de evidencia
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

  // Agregar archivo de evidencia
  void addEvidenceFile(String filePath) {
    _evidenceFiles.add(filePath);
    notifyListeners();
  }

  // Obtener ubicación actual
  Future<String> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Servicio de ubicación deshabilitado';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Permiso de ubicación denegado';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Permiso de ubicación permanentemente denegado';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return '${position.latitude}, ${position.longitude}';
    } catch (e) {
      return 'Error obteniendo ubicación: $e';
    }
  }

  // Enviar alerta SOS
  Future<void> _sendSosAlert() async {
    try {
      // Aquí se implementaría el envío real de alertas
      // Por ahora solo simulamos el envío
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('Alerta SOS enviada a contactos de confianza');
    } catch (e) {
      debugPrint('Error enviando alerta SOS: $e');
    }
  }

  // Cargar historial desde almacenamiento local
  Future<void> loadSosHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? historyJson = prefs.getString('sos_history');
      if (historyJson != null) {
        // Aquí se parsearía el JSON del historial
        // Por ahora mantenemos la lista vacía
      }
    } catch (e) {
      debugPrint('Error cargando historial SOS: $e');
    }
  }

  // Guardar historial en almacenamiento local
  Future<void> saveSosHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Aquí se convertiría el historial a JSON
      // Por ahora solo simulamos el guardado
    } catch (e) {
      debugPrint('Error guardando historial SOS: $e');
    }
  }
}
