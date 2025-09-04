import 'package:flutter/material.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WhatsAppService {
  static const String _contactsKey = 'emergency_contacts';

  // Agregar contacto de emergencia
  static Future<void> addEmergencyContact({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_contactsKey) ?? '[]';
      final List<dynamic> contacts = json.decode(contactsJson);

      // Verificar si el contacto ya existe
      final existingIndex = contacts.indexWhere(
        (contact) => contact['phone'] == phoneNumber,
      );

      if (existingIndex != -1) {
        contacts[existingIndex] = {
          'name': name,
          'phone': phoneNumber,
          'addedAt': DateTime.now().toIso8601String(),
        };
      } else {
        contacts.add({
          'name': name,
          'phone': phoneNumber,
          'addedAt': DateTime.now().toIso8601String(),
        });
      }

      await prefs.setString(_contactsKey, json.encode(contacts));
    } catch (e) {
      debugPrint('Error agregando contacto: $e');
    }
  }

  // Obtener contactos de emergencia
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_contactsKey) ?? '[]';
      final List<dynamic> contacts = json.decode(contactsJson);

      return contacts.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error obteniendo contactos: $e');
      return [];
    }
  }

  // Eliminar contacto de emergencia
  static Future<void> removeEmergencyContact(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString(_contactsKey) ?? '[]';
      final List<dynamic> contacts = json.decode(contactsJson);

      contacts.removeWhere((contact) => contact['phone'] == phoneNumber);

      await prefs.setString(_contactsKey, json.encode(contacts));
    } catch (e) {
      debugPrint('Error eliminando contacto: $e');
    }
  }

  // Enviar mensaje SOS a todos los contactos
  static Future<void> sendSosToAllContacts({
    required String message,
    required String location,
    required String timestamp,
  }) async {
    try {
      final contacts = await getEmergencyContacts();

      for (final contact in contacts) {
        await _sendWhatsAppMessage(
          phoneNumber: contact['phone'],
          message: _buildSosMessage(
            message: message,
            location: location,
            timestamp: timestamp,
            contactName: contact['name'],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error enviando SOS a contactos: $e');
    }
  }

  // Enviar ubicación en tiempo real
  static Future<void> shareLocation({
    required String phoneNumber,
    required String location,
    required String message,
  }) async {
    try {
      final locationMessage = '''
🛡️ *PREVENCIÓN SEGURA* 🛡️

📍 *Ubicación Compartida*
$message

🗺️ *Coordenadas:* $location
⏰ *Hora:* ${DateTime.now().toString()}

*Esta ubicación fue compartida automáticamente por la app Prevención Segura*
''';

      await _sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: locationMessage,
      );
    } catch (e) {
      debugPrint('Error compartiendo ubicación: $e');
    }
  }

  // Enviar mensaje personalizado
  static Future<void> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      await _sendWhatsAppMessage(phoneNumber: phoneNumber, message: message);
    } catch (e) {
      debugPrint('Error enviando mensaje personalizado: $e');
    }
  }

  // Construir mensaje SOS
  static String _buildSosMessage({
    required String message,
    required String location,
    required String timestamp,
    required String contactName,
  }) {
    return '''
🚨 *ALERTA SOS* 🚨

Hola $contactName,

*¡EMERGENCIA!* Necesito ayuda inmediata.

📝 *Situación:* $message
📍 *Ubicación:* $location
⏰ *Hora:* $timestamp

*Por favor, contacta a las autoridades o ven a ayudarme.*

*Este mensaje fue enviado automáticamente por la app Prevención Segura*
''';
  }

  // Enviar mensaje por WhatsApp
  static Future<void> _sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Limpiar número de teléfono
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Crear enlace de WhatsApp
      final link = WhatsAppUnilink(phoneNumber: cleanPhone, text: message);

      // Abrir WhatsApp
      if (await canLaunchUrl(link.asUri())) {
        await launchUrl(link.asUri());
      } else {
        debugPrint('No se puede abrir WhatsApp');
      }
    } catch (e) {
      debugPrint('Error enviando mensaje por WhatsApp: $e');
    }
  }

  // Verificar si WhatsApp está instalado
  static Future<bool> isWhatsAppInstalled() async {
    try {
      const url = 'whatsapp://send';
      return await canLaunchUrl(Uri.parse(url));
    } catch (e) {
      return false;
    }
  }

  // Enviar mensaje de prueba
  static Future<void> sendTestMessage(String phoneNumber) async {
    try {
      const testMessage = '''
🛡️ *PREVENCIÓN SEGURA* 🛡️

*Mensaje de Prueba*

Hola! Este es un mensaje de prueba de la aplicación Prevención Segura.

Si recibes este mensaje, significa que la configuración está funcionando correctamente.

*¡Gracias por ser parte de mi red de seguridad!*
''';

      await _sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: testMessage,
      );
    } catch (e) {
      debugPrint('Error enviando mensaje de prueba: $e');
    }
  }
}
