import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      // Aquí se enviaría la alerta a contactos de confianza
      await _sendSosAlert();

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
  void startRecording() {
    _isRecording = true;
    notifyListeners();
  }

  // Detener grabación de evidencia
  void stopRecording() {
    _isRecording = false;
    notifyListeners();
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
