import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _hasLocationPermission = false;
  String _locationStatus = 'Verificando permisos...';
  List<Position> _locationHistory = [];

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get hasLocationPermission => _hasLocationPermission;
  String get locationStatus => _locationStatus;
  List<Position> get locationHistory => _locationHistory;

  LocationProvider() {
    _initializeLocation();
  }

  // Inicializar servicios de ubicación
  Future<void> _initializeLocation() async {
    await _checkLocationService();
    await _checkLocationPermission();
  }

  // Verificar si el servicio de ubicación está habilitado
  Future<void> _checkLocationService() async {
    try {
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (_isLocationEnabled) {
        _locationStatus = 'Servicio de ubicación habilitado';
      } else {
        _locationStatus = 'Servicio de ubicación deshabilitado';
      }
      notifyListeners();
    } catch (e) {
      _locationStatus = 'Error verificando servicio de ubicación';
      debugPrint('Error verificando servicio de ubicación: $e');
    }
  }

  // Verificar permisos de ubicación
  Future<void> _checkLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.status;

      if (status.isGranted) {
        _hasLocationPermission = true;
        _locationStatus = 'Permiso de ubicación concedido';
        await _getCurrentLocation();
      } else if (status.isDenied) {
        _hasLocationPermission = false;
        _locationStatus = 'Permiso de ubicación denegado';
      } else if (status.isPermanentlyDenied) {
        _hasLocationPermission = false;
        _locationStatus = 'Permiso de ubicación permanentemente denegado';
      }

      notifyListeners();
    } catch (e) {
      _locationStatus = 'Error verificando permisos de ubicación';
      debugPrint('Error verificando permisos de ubicación: $e');
    }
  }

  // Solicitar permisos de ubicación
  Future<void> requestLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.request();

      if (status.isGranted) {
        _hasLocationPermission = true;
        _locationStatus = 'Permiso de ubicación concedido';
        await _getCurrentLocation();
      } else {
        _hasLocationPermission = false;
        _locationStatus = 'Permiso de ubicación denegado';
      }

      notifyListeners();
    } catch (e) {
      _locationStatus = 'Error solicitando permisos de ubicación';
      debugPrint('Error solicitando permisos de ubicación: $e');
    }
  }

  // Obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    try {
      if (!_hasLocationPermission) {
        _locationStatus = 'Sin permisos de ubicación';
        return;
      }

      _locationStatus = 'Obteniendo ubicación...';
      notifyListeners();

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = position;
      _locationHistory.add(position);

      // Mantener solo las últimas 100 ubicaciones
      if (_locationHistory.length > 100) {
        _locationHistory.removeAt(0);
      }

      _locationStatus = 'Ubicación obtenida exitosamente';
      notifyListeners();
    } catch (e) {
      _locationStatus = 'Error obteniendo ubicación: $e';
      debugPrint('Error obteniendo ubicación: $e');
      notifyListeners();
    }
  }

  // Actualizar ubicación en tiempo real
  Future<void> updateLocation() async {
    if (_hasLocationPermission && _isLocationEnabled) {
      await _getCurrentLocation();
    }
  }

  // Obtener distancia entre dos puntos
  double getDistanceBetweenPoints(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Obtener dirección desde coordenadas
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Por ahora retornamos coordenadas como dirección
      // En una implementación real se usaría un servicio de geocodificación
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      debugPrint('Error obteniendo dirección: $e');
      return 'Error obteniendo dirección';
    }
  }

  // Obtener ubicación aproximada (menor precisión, más rápida)
  Future<void> getApproximateLocation() async {
    try {
      if (!_hasLocationPermission) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      debugPrint('Error obteniendo ubicación aproximada: $e');
    }
  }

  // Limpiar historial de ubicaciones
  void clearLocationHistory() {
    _locationHistory.clear();
    notifyListeners();
  }

  // Obtener estadísticas de ubicación
  Map<String, dynamic> getLocationStats() {
    if (_locationHistory.isEmpty) {
      return {'totalLocations': 0, 'averageSpeed': 0.0, 'totalDistance': 0.0};
    }

    double totalDistance = 0.0;
    double totalSpeed = 0.0;

    for (int i = 1; i < _locationHistory.length; i++) {
      totalDistance += getDistanceBetweenPoints(
        _locationHistory[i - 1],
        _locationHistory[i],
      );

      if (_locationHistory[i].speed > 0) {
        totalSpeed += _locationHistory[i].speed;
      }
    }

    return {
      'totalLocations': _locationHistory.length,
      'averageSpeed': totalSpeed / _locationHistory.length,
      'totalDistance': totalDistance,
    };
  }
}
