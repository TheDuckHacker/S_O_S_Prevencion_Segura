import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';

class RecordingService {
  static final AudioRecorder _audioRecorder = AudioRecorder();
  static CameraController? _cameraController;
  static bool _isRecordingAudio = false;
  static bool _isRecordingVideo = false;
  static String? _currentAudioPath;
  static String? _currentVideoPath;

  // Inicializar cámara
  static Future<CameraController?> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No hay cámaras disponibles');
        return null;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      return _cameraController;
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
      return null;
    }
  }

  // Solicitar permisos de grabación
  static Future<bool> requestRecordingPermissions() async {
    try {
      // Permisos de audio
      final audioStatus = await Permission.microphone.request();
      if (!audioStatus.isGranted) {
        debugPrint('Permiso de micrófono denegado');
        return false;
      }

      // Permisos de cámara
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        debugPrint('Permiso de cámara denegado');
        return false;
      }

      // Permisos de almacenamiento
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        debugPrint('Permiso de almacenamiento denegado');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error solicitando permisos: $e');
      return false;
    }
  }

  // Iniciar grabación de audio
  static Future<bool> startAudioRecording() async {
    try {
      if (_isRecordingAudio) {
        debugPrint('Ya se está grabando audio');
        return false;
      }

      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        debugPrint('No hay permisos para grabar audio');
        return false;
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentAudioPath = '${directory.path}/sos_audio_$timestamp.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentAudioPath!,
      );

      _isRecordingAudio = true;
      debugPrint('Grabación de audio iniciada: $_currentAudioPath');
      return true;
    } catch (e) {
      debugPrint('Error iniciando grabación de audio: $e');
      return false;
    }
  }

  // Detener grabación de audio
  static Future<String?> stopAudioRecording() async {
    try {
      if (!_isRecordingAudio) {
        debugPrint('No hay grabación de audio activa');
        return null;
      }

      final path = await _audioRecorder.stop();
      _isRecordingAudio = false;
      _currentAudioPath = null;

      debugPrint('Grabación de audio detenida: $path');
      return path;
    } catch (e) {
      debugPrint('Error deteniendo grabación de audio: $e');
      return null;
    }
  }

  // Iniciar grabación de video
  static Future<bool> startVideoRecording() async {
    try {
      if (_isRecordingVideo) {
        debugPrint('Ya se está grabando video');
        return false;
      }

      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        debugPrint('Cámara no inicializada');
        return false;
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentVideoPath = '${directory.path}/sos_video_$timestamp.mp4';

      await _cameraController!.startVideoRecording();
      _isRecordingVideo = true;

      debugPrint('Grabación de video iniciada: $_currentVideoPath');
      return true;
    } catch (e) {
      debugPrint('Error iniciando grabación de video: $e');
      return false;
    }
  }

  // Detener grabación de video
  static Future<String?> stopVideoRecording() async {
    try {
      if (!_isRecordingVideo) {
        debugPrint('No hay grabación de video activa');
        return null;
      }

      final videoFile = await _cameraController!.stopVideoRecording();
      _isRecordingVideo = false;

      // Mover el archivo a la ubicación deseada
      if (_currentVideoPath != null) {
        await videoFile.saveTo(_currentVideoPath!);
        debugPrint('Grabación de video detenida: $_currentVideoPath');
        return _currentVideoPath;
      }

      return videoFile.path;
    } catch (e) {
      debugPrint('Error deteniendo grabación de video: $e');
      return null;
    }
  }

  // Obtener estado de grabación
  static bool get isRecordingAudio => _isRecordingAudio;
  static bool get isRecordingVideo => _isRecordingVideo;
  static bool get isRecording => _isRecordingAudio || _isRecordingVideo;

  // Obtener duración de grabación
  static Future<Duration?> getRecordingDuration() async {
    try {
      if (_isRecordingAudio) {
        return await _audioRecorder.getAmplitude();
      }
      return null;
    } catch (e) {
      debugPrint('Error obteniendo duración: $e');
      return null;
    }
  }

  // Obtener amplitud del audio
  static Future<Amplitude> getAudioAmplitude() async {
    try {
      return await _audioRecorder.getAmplitude();
    } catch (e) {
      debugPrint('Error obteniendo amplitud: $e');
      return const Amplitude(current: 0.0, max: 0.0);
    }
  }

  // Capturar foto
  static Future<String?> capturePhoto() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        debugPrint('Cámara no inicializada');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final photoPath = '${directory.path}/sos_photo_$timestamp.jpg';

      final photoFile = await _cameraController!.takePicture();
      await photoFile.saveTo(photoPath);

      debugPrint('Foto capturada: $photoPath');
      return photoPath;
    } catch (e) {
      debugPrint('Error capturando foto: $e');
      return null;
    }
  }

  // Obtener tamaño del archivo
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error obteniendo tamaño del archivo: $e');
      return 0;
    }
  }

  // Eliminar archivo
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Archivo eliminado: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error eliminando archivo: $e');
      return false;
    }
  }

  // Obtener lista de archivos de evidencia
  static Future<List<Map<String, dynamic>>> getEvidenceFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      final evidenceFiles = <Map<String, dynamic>>[];

      for (final file in files) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          if (fileName.startsWith('sos_')) {
            final stat = await file.stat();
            evidenceFiles.add({
              'path': file.path,
              'name': fileName,
              'size': stat.size,
              'modified': stat.modified,
              'type': _getFileType(fileName),
            });
          }
        }
      }

      // Ordenar por fecha de modificación (más recientes primero)
      evidenceFiles.sort(
        (a, b) =>
            (b['modified'] as DateTime).compareTo(a['modified'] as DateTime),
      );

      return evidenceFiles;
    } catch (e) {
      debugPrint('Error obteniendo archivos de evidencia: $e');
      return [];
    }
  }

  // Determinar tipo de archivo
  static String _getFileType(String fileName) {
    if (fileName.contains('audio')) return 'audio';
    if (fileName.contains('video')) return 'video';
    if (fileName.contains('photo')) return 'photo';
    return 'unknown';
  }

  // Liberar recursos
  static Future<void> dispose() async {
    try {
      if (_isRecordingAudio) {
        await stopAudioRecording();
      }

      if (_isRecordingVideo) {
        await stopVideoRecording();
      }

      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      await _audioRecorder.dispose();
    } catch (e) {
      debugPrint('Error liberando recursos: $e');
    }
  }
}
