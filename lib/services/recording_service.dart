import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio simplificado para grabación de evidencia
class RecordingService {
  static CameraController? _cameraController;
  static bool _isRecordingVideo = false;
  static List<String> _evidenceFiles = [];

  // Inicializar cámara
  static Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: true,
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
    }
  }

  // Iniciar grabación de video
  static Future<bool> startVideoRecording() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await initializeCamera();
      }

      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/evidence_${DateTime.now().millisecondsSinceEpoch}.mp4';
        
        await _cameraController!.startVideoRecording();
        _isRecordingVideo = true;
        _evidenceFiles.add(path);
        
        debugPrint('Grabación de video iniciada: $path');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error iniciando grabación de video: $e');
      return false;
    }
  }

  // Detener grabación de video
  static Future<String?> stopVideoRecording() async {
    try {
      if (_cameraController != null && _isRecordingVideo) {
        final file = await _cameraController!.stopVideoRecording();
        _isRecordingVideo = false;
        
        debugPrint('Grabación de video detenida: ${file.path}');
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error deteniendo grabación de video: $e');
      return null;
    }
  }

  // Capturar foto
  static Future<String?> capturePhoto() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await initializeCamera();
      }

      if (_cameraController != null && _cameraController!.value.isInitialized) {
        final file = await _cameraController!.takePicture();
        _evidenceFiles.add(file.path);
        
        debugPrint('Foto capturada: ${file.path}');
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error capturando foto: $e');
      return null;
    }
  }

  // Obtener archivos de evidencia
  static List<String> getEvidenceFiles() => List.from(_evidenceFiles);

  // Limpiar archivos de evidencia
  static void clearEvidenceFiles() {
    _evidenceFiles.clear();
  }

  // Obtener estado de grabación
  static bool get isRecordingVideo => _isRecordingVideo;
  static bool get isRecording => _isRecordingVideo;

  // Obtener duración de grabación (simplificado)
  static Future<Duration?> getRecordingDuration() async {
    // Implementación simplificada - retorna duración estimada
    return _isRecordingVideo ? Duration(seconds: 30) : null;
  }

  // Obtener amplitud del audio (simulada)
  static Future<Map<String, double>> getAudioAmplitude() async {
    // Implementación simplificada - retorna valores simulados
    return {
      'current': _isRecordingVideo ? 0.5 : 0.0,
      'max': _isRecordingVideo ? 0.8 : 0.0,
    };
  }

  // Liberar recursos
  static Future<void> dispose() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }
}