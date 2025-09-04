import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

/// Servicio simplificado para grabación de evidencia
class RecordingService {
  static CameraController? _cameraController;
  static bool _isRecordingVideo = false;
  static List<String> _evidenceFiles = [];

  // Inicializar cámara solo cuando sea necesario
  static Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No se encontraron cámaras disponibles');
        return;
      }

      // Intentar con diferentes cámaras y configuraciones
      for (final camera in cameras) {
        try {
          debugPrint('Intentando inicializar cámara: ${camera.name}');
          
          _cameraController = CameraController(
            camera,
            ResolutionPreset.low, // Usar la resolución más baja posible
            enableAudio: false, // Deshabilitar audio completamente
            imageFormatGroup: ImageFormatGroup.jpeg, // Usar JPEG para mejor compatibilidad
          );
          
          await _cameraController!.initialize();
          debugPrint('✅ Cámara inicializada correctamente: ${camera.name}');
          return; // Si llegamos aquí, la cámara se inicializó correctamente
          
        } catch (cameraError) {
          debugPrint('❌ Error con cámara ${camera.name}: $cameraError');
          
          // Liberar recursos de esta cámara
          try {
            await _cameraController?.dispose();
            _cameraController = null;
          } catch (disposeError) {
            debugPrint('Error liberando cámara ${camera.name}: $disposeError');
          }
          
          // Continuar con la siguiente cámara
          continue;
        }
      }
      
      // Si llegamos aquí, ninguna cámara funcionó
      debugPrint('❌ No se pudo inicializar ninguna cámara');
      
    } catch (e) {
      debugPrint('❌ Error general inicializando cámaras: $e');
    }
  }

  // Iniciar grabación de video
  static Future<bool> startVideoRecording() async {
    try {
      // Verificar si ya se está grabando
      if (_isRecordingVideo) {
        debugPrint('Ya se está grabando un video');
        return true;
      }

      // Intentar inicializar la cámara si no está lista
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        await initializeCamera();
      }

      // Verificar si la cámara está disponible
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        debugPrint('Cámara no disponible para grabación');
        return false;
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/evidence_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      await _cameraController!.startVideoRecording();
      _isRecordingVideo = true;
      _evidenceFiles.add(path);
      
      debugPrint('Grabación de video iniciada: $path');
      return true;
    } catch (e) {
      debugPrint('Error iniciando grabación de video: $e');
      
      // Intentar liberar recursos en caso de error
      try {
        await _cameraController?.dispose();
        _cameraController = null;
      } catch (disposeError) {
        debugPrint('Error liberando cámara después de error: $disposeError');
      }
      
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
      _isRecordingVideo = false;
      debugPrint('Recursos de cámara liberados');
    }
  }

  // Verificar si la cámara está disponible
  static bool isCameraAvailable() {
    return _cameraController != null && _cameraController!.value.isInitialized;
  }

  // Obtener información de dónde se guardan las grabaciones
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final evidencePath = '${directory.path}/evidence';
      
      return {
        'documentsPath': directory.path,
        'evidencePath': evidencePath,
        'totalFiles': _evidenceFiles.length,
        'files': List.from(_evidenceFiles),
        'cameraAvailable': isCameraAvailable(),
        'isRecording': _isRecordingVideo,
      };
    } catch (e) {
      debugPrint('Error obteniendo información de almacenamiento: $e');
      return {
        'error': e.toString(),
        'cameraAvailable': false,
        'isRecording': false,
      };
    }
  }

  // Mostrar información de almacenamiento
  static Future<void> showStorageInfo(BuildContext context) async {
    final info = await getStorageInfo();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.folder, color: Colors.blue),
            SizedBox(width: 10),
            Text('Ubicación de Grabaciones'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (info['error'] != null) ...[
              Text('❌ Error: ${info['error']}'),
            ] else ...[
              Text('📁 Directorio de documentos:'),
              Text('${info['documentsPath']}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              Text('🎥 Archivos de evidencia: ${info['totalFiles']}'),
              const SizedBox(height: 5),
              if (info['files'].isNotEmpty) ...[
                const Text('📄 Archivos guardados:'),
                ...info['files'].map<Widget>((file) => 
                  Text('• ${file.split('/').last}', style: const TextStyle(fontSize: 12))
                ).toList(),
              ],
              const SizedBox(height: 10),
              Text('📷 Cámara disponible: ${info['cameraAvailable'] ? '✅ Sí' : '❌ No'}'),
              Text('🔴 Grabando: ${info['isRecording'] ? '✅ Sí' : '❌ No'}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}