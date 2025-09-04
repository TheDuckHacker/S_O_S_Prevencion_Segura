import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class RealtimeWhatsAppService {
  static Timer? _locationTimer;
  static bool _isSharingLocation = false;
  static const String _isSharingKey = 'is_sharing_location';
  static const String _sharingDurationKey = 'sharing_duration';

  // Iniciar compartir ubicación en tiempo real
  static Future<void> startRealtimeLocationSharing({
    required String threatDescription,
    required String additionalText,
    required List<String> phoneNumbers,
    int durationMinutes = 60, // Duración por defecto: 1 hora
  }) async {
    if (_isSharingLocation) {
      debugPrint('Ya se está compartiendo ubicación en tiempo real');
      return;
    }

    _isSharingLocation = true;
    await _saveSharingStatus(true, durationMinutes);

    debugPrint('🚀 Iniciando compartir ubicación en tiempo real por WhatsApp');

    // Enviar mensaje inicial
    await _sendInitialLocationMessage(
      threatDescription: threatDescription,
      additionalText: additionalText,
      phoneNumbers: phoneNumbers,
    );

    // Iniciar timer para enviar ubicación cada 30 segundos
    _locationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        await _sendLocationUpdate(phoneNumbers);
      },
    );

    // Programar parada automática
    Timer(
      Duration(minutes: durationMinutes),
      () {
        stopRealtimeLocationSharing();
      },
    );
  }

  // Detener compartir ubicación en tiempo real
  static Future<void> stopRealtimeLocationSharing() async {
    if (!_isSharingLocation) return;

    _isSharingLocation = false;
    _locationTimer?.cancel();
    _locationTimer = null;

    await _saveSharingStatus(false, 0);
    debugPrint('🛑 Deteniendo compartir ubicación en tiempo real');
  }

  // Verificar si se está compartiendo ubicación
  static Future<bool> isSharingLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSharingKey) ?? false;
  }

  // Enviar mensaje inicial con ubicación
  static Future<void> _sendInitialLocationMessage({
    required String threatDescription,
    required String additionalText,
    required List<String> phoneNumbers,
  }) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      final location = '${position.latitude}, ${position.longitude}';
      final googleMapsUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      final message = '''🚨 *ALERTA SOS ACTIVA* 🚨

*Descripción:* $threatDescription${additionalText.isNotEmpty ? ' - $additionalText' : ''}

📍 *Mi ubicación actual:* $location
🔗 *Ver en Google Maps:* $googleMapsUrl

⏰ *Hora:* ${DateTime.now().toString()}

🔄 *UBICACIÓN EN TIEMPO REAL ACTIVADA*
• Se compartirá mi ubicación cada 30 segundos
• Duración: 60 minutos
• La ubicación se actualiza automáticamente

*Esta alerta fue enviada automáticamente por la app Prevención Segura*''';

      // Enviar a todos los números
      for (final phoneNumber in phoneNumbers) {
        await _sendWhatsAppMessage(phoneNumber, message);
        await Future.delayed(const Duration(milliseconds: 500));
      }

    } catch (e) {
      debugPrint('Error enviando mensaje inicial: $e');
    }
  }

  // Enviar actualización de ubicación
  static Future<void> _sendLocationUpdate(List<String> phoneNumbers) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 10),
      );

      final location = '${position.latitude}, ${position.longitude}';
      final googleMapsUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      final message = '''📍 *ACTUALIZACIÓN DE UBICACIÓN*

*Ubicación actual:* $location
*Precisión:* ${position.accuracy.toStringAsFixed(1)}m
*Hora:* ${DateTime.now().toString()}

🔗 *Ver en Google Maps:* $googleMapsUrl

*Ubicación en tiempo real - Prevención Segura*''';

      // Enviar a todos los números
      for (final phoneNumber in phoneNumbers) {
        await _sendWhatsAppMessage(phoneNumber, message);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      debugPrint('📍 Ubicación actualizada enviada: $location');

    } catch (e) {
      debugPrint('Error enviando actualización de ubicación: $e');
    }
  }

  // Enviar mensaje por WhatsApp
  static Future<void> _sendWhatsAppMessage(String phoneNumber, String message) async {
    try {
      final encodedMessage = Uri.encodeComponent(message);
      final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error enviando mensaje a $phoneNumber: $e');
    }
  }

  // Guardar estado de compartir ubicación
  static Future<void> _saveSharingStatus(bool isSharing, int duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSharingKey, isSharing);
      await prefs.setInt(_sharingDurationKey, duration);
    } catch (e) {
      debugPrint('Error guardando estado de compartir ubicación: $e');
    }
  }

  // Obtener contactos de emergencia
  static Future<List<String>> getEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString('emergency_contacts');
      
      if (contactsJson != null) {
        final List<dynamic> contacts = 
            (prefs.getString('emergency_contacts') ?? '[]').split(',');
        return contacts.where((contact) => contact.toString().isNotEmpty).cast<String>().toList();
      }
    } catch (e) {
      debugPrint('Error obteniendo contactos de emergencia: $e');
    }
    
    return [];
  }

  // Inicializar servicio
  static Future<void> initialize() async {
    final isSharing = await isSharingLocation();
    if (isSharing) {
      // Si se estaba compartiendo antes de cerrar la app, reanudar
      final contacts = await getEmergencyContacts();
      if (contacts.isNotEmpty) {
        await startRealtimeLocationSharing(
          threatDescription: 'Reanudando alerta SOS',
          additionalText: 'La app se reinició',
          phoneNumbers: contacts,
        );
      }
    }
  }
}
