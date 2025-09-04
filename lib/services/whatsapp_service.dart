import 'package:flutter/material.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WhatsAppService {
  static const String _contactsKey = 'emergency_contacts';

  // Agregar contacto de emergencia (solo si tiene WhatsApp)
  static Future<bool> addEmergencyContact({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      // Verificar si el número tiene WhatsApp
      final hasWhatsApp = await _verifyWhatsAppNumber(phoneNumber);

      if (!hasWhatsApp) {
        debugPrint('El número $phoneNumber no tiene WhatsApp');
        return false;
      }

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
          'hasWhatsApp': true,
        };
      } else {
        contacts.add({
          'name': name,
          'phone': phoneNumber,
          'addedAt': DateTime.now().toIso8601String(),
          'hasWhatsApp': true,
        });
      }

      await prefs.setString(_contactsKey, json.encode(contacts));
      return true;
    } catch (e) {
      debugPrint('Error agregando contacto: $e');
      return false;
    }
  }

  // Verificar si un número tiene WhatsApp
  static Future<bool> _verifyWhatsAppNumber(String phoneNumber) async {
    try {
      // Limpiar el número de teléfono
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Crear enlace de prueba
      final testLink = WhatsAppUnilink(phoneNumber: cleanPhone, text: 'Test');

      final uri = Uri.parse(testLink.toString());
      return await canLaunchUrl(uri);
    } catch (e) {
      debugPrint('Error verificando WhatsApp: $e');
      return false;
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

  // Enviar alerta SOS a todos los contactos automáticamente
  static Future<void> sendSosToAllContacts({
    required String message,
    required String location,
  }) async {
    try {
      final contacts = await getEmergencyContacts();

      if (contacts.isEmpty) {
        debugPrint('No hay contactos de emergencia configurados');
        return;
      }

      // Enviar a todos los contactos que tengan WhatsApp
      for (final contact in contacts) {
        if (contact['hasWhatsApp'] == true) {
          await _sendSosMessage(
            phoneNumber: contact['phone'],
            message: message,
            location: location,
            contactName: contact['name'],
          );

          // Pequeña pausa entre envíos para evitar spam
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      debugPrint('Error enviando SOS a contactos: $e');
    }
  }

  // Enviar mensaje SOS individual
  static Future<void> _sendSosMessage({
    required String phoneNumber,
    required String message,
    required String location,
    required String contactName,
  }) async {
    try {
      final sosMessage = '''
🚨 *ALERTA DE EMERGENCIA SOS* 🚨

Hola $contactName,

*Se ha activado una alerta de emergencia SOS.*

📝 *Descripción:* $message
📍 *Mi ubicación actual:* $location
⏰ *Hora:* ${DateTime.now().toString()}
🔗 *Ver en Google Maps:* https://www.google.com/maps?q=${location.split(' ')[0]},${location.split(' ')[1]}

*ACCIÓN INMEDIATA REQUERIDA:*
• Contacta inmediatamente a la persona
• Llama a las autoridades locales
• Comparte esta ubicación con otros contactos
• Mantén comunicación constante

*Esta alerta fue enviada automáticamente por la app Prevención Segura*
*La ubicación se actualiza en tiempo real*
''';

      await _sendWhatsAppMessage(phoneNumber: phoneNumber, message: sosMessage);
    } catch (e) {
      debugPrint('Error enviando mensaje SOS: $e');
    }
  }

  // Enviar grabación por WhatsApp
  static Future<void> sendRecordingToAllContacts({
    required String filePath,
    required String message,
    required String location,
  }) async {
    try {
      final contacts = await getEmergencyContacts();

      if (contacts.isEmpty) {
        debugPrint('No hay contactos de emergencia configurados');
        return;
      }

      for (final contact in contacts) {
        await _sendRecordingMessage(
          phoneNumber: contact['phone'],
          filePath: filePath,
          message: message,
          location: location,
          contactName: contact['name'],
        );
      }
    } catch (e) {
      debugPrint('Error enviando grabación a contactos: $e');
    }
  }

  // Enviar mensaje con grabación
  static Future<void> _sendRecordingMessage({
    required String phoneNumber,
    required String filePath,
    required String message,
    required String location,
    required String contactName,
  }) async {
    try {
      final recordingMessage = '''
🎥 *EVIDENCIA GRABADA* 🎥

Hola $contactName,

*Se ha grabado evidencia de una situación de emergencia.*

📝 *Descripción:* $message
📍 *Ubicación:* $location
⏰ *Hora:* ${DateTime.now().toString()}

*Archivo de evidencia:* $filePath

*Esta evidencia fue grabada automáticamente por la app Prevención Segura*
''';

      await _sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: recordingMessage,
      );
    } catch (e) {
      debugPrint('Error enviando mensaje con grabación: $e');
    }
  }

  // Enviar mensaje de prueba
  static Future<void> sendTestMessage(String phoneNumber) async {
    try {
      final testMessage = '''
✅ *MENSAJE DE PRUEBA* ✅

Hola! Este es un mensaje de prueba de la app Prevención Segura.

Si recibes este mensaje, significa que las alertas SOS funcionarán correctamente.

⏰ *Hora de prueba:* ${DateTime.now().toString()}

*App: Prevención Segura - Sistema de Emergencias*
''';

      await _sendWhatsAppMessage(
        phoneNumber: phoneNumber,
        message: testMessage,
      );
    } catch (e) {
      debugPrint('Error enviando mensaje de prueba: $e');
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

  // Método principal para enviar mensajes por WhatsApp
  static Future<void> _sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Limpiar el número de teléfono
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Crear el enlace de WhatsApp
      final whatsappLink = WhatsAppUnilink(
        phoneNumber: cleanPhone,
        text: message,
      );

      // Abrir WhatsApp
      final url = whatsappLink.toString();
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('WhatsApp abierto para: $cleanPhone');
      } else {
        debugPrint('No se pudo abrir WhatsApp para: $cleanPhone');
      }
    } catch (e) {
      debugPrint('Error enviando mensaje por WhatsApp: $e');
    }
  }

  // Obtener estadísticas de contactos
  static Future<Map<String, dynamic>> getContactStats() async {
    try {
      final contacts = await getEmergencyContacts();
      return {
        'totalContacts': contacts.length,
        'lastUpdated':
            contacts.isNotEmpty
                ? contacts
                    .map((c) => c['addedAt'])
                    .reduce((a, b) => a.compareTo(b) > 0 ? a : b)
                : null,
      };
    } catch (e) {
      debugPrint('Error obteniendo estadísticas: $e');
      return {'totalContacts': 0, 'lastUpdated': null};
    }
  }

  // Verificar si WhatsApp está instalado
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final uri = Uri.parse('whatsapp://send?phone=1234567890&text=test');
      return await canLaunchUrl(uri);
    } catch (e) {
      debugPrint('Error verificando WhatsApp: $e');
      return false;
    }
  }

  // Exportar contactos
  static Future<String> exportContacts() async {
    try {
      final contacts = await getEmergencyContacts();
      return json.encode(contacts);
    } catch (e) {
      debugPrint('Error exportando contactos: $e');
      return '[]';
    }
  }

  // Importar contactos
  static Future<void> importContacts(String contactsJson) async {
    try {
      final List<dynamic> contacts = json.decode(contactsJson);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_contactsKey, json.encode(contacts));
    } catch (e) {
      debugPrint('Error importando contactos: $e');
    }
  }
}
