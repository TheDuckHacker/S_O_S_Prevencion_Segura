import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class WhatsAppBusinessAPI {
  // Configuración de WhatsApp Business API
  static const String _baseUrl = 'https://graph.facebook.com/v18.0';
  static String? _accessToken;
  static String? _phoneNumberId;
  static String? _businessAccountId;

  // Inicializar la API
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('whatsapp_access_token');
      _phoneNumberId = prefs.getString('whatsapp_phone_number_id');
      _businessAccountId = prefs.getString('whatsapp_business_account_id');

      debugPrint('WhatsApp Business API inicializada');
      debugPrint(
        'Token: ${_accessToken != null ? "✅ Configurado" : "❌ No configurado"}',
      );
      debugPrint('Phone Number ID: ${_phoneNumberId ?? "No configurado"}');
    } catch (e) {
      debugPrint('Error inicializando WhatsApp Business API: $e');
    }
  }

  // Configurar credenciales
  static Future<void> configure({
    required String accessToken,
    required String phoneNumberId,
    required String businessAccountId,
  }) async {
    try {
      _accessToken = accessToken;
      _phoneNumberId = phoneNumberId;
      _businessAccountId = businessAccountId;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('whatsapp_access_token', accessToken);
      await prefs.setString('whatsapp_phone_number_id', phoneNumberId);
      await prefs.setString('whatsapp_business_account_id', businessAccountId);

      debugPrint('✅ WhatsApp Business API configurada correctamente');
    } catch (e) {
      debugPrint('Error configurando WhatsApp Business API: $e');
    }
  }

  // Verificar si está configurada
  static bool isConfigured() {
    return _accessToken != null &&
        _phoneNumberId != null &&
        _businessAccountId != null;
  }

  // Enviar mensaje de texto
  static Future<bool> sendTextMessage({
    required String to,
    required String message,
  }) async {
    if (!isConfigured()) {
      debugPrint('❌ WhatsApp Business API no está configurada');
      return false;
    }

    try {
      final url = '$_baseUrl/$_phoneNumberId/messages';
      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

      final body = {
        'messaging_product': 'whatsapp',
        'to': to,
        'type': 'text',
        'text': {'body': message},
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Mensaje enviado a $to');
        return true;
      } else {
        debugPrint(
          '❌ Error enviando mensaje: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error enviando mensaje: $e');
      return false;
    }
  }

  // Enviar ubicación en tiempo real (Location Template)
  static Future<bool> sendLiveLocation({
    required String to,
    required double latitude,
    required double longitude,
    required String name,
    required String address,
    required int durationMinutes,
  }) async {
    if (!isConfigured()) {
      debugPrint('❌ WhatsApp Business API no está configurada');
      return false;
    }

    try {
      final url = '$_baseUrl/$_phoneNumberId/messages';
      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

      final body = {
        'messaging_product': 'whatsapp',
        'to': to,
        'type': 'location',
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'name': name,
          'address': address,
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Ubicación en tiempo real enviada a $to');
        return true;
      } else {
        debugPrint(
          '❌ Error enviando ubicación: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error enviando ubicación: $e');
      return false;
    }
  }

  // Enviar template de ubicación en tiempo real
  static Future<bool> sendLiveLocationTemplate({
    required String to,
    required double latitude,
    required double longitude,
    required String threatDescription,
    required int durationMinutes,
  }) async {
    if (!isConfigured()) {
      debugPrint('❌ WhatsApp Business API no está configurada');
      return false;
    }

    try {
      final url = '$_baseUrl/$_phoneNumberId/messages';
      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

      final body = {
        'messaging_product': 'whatsapp',
        'to': to,
        'type': 'template',
        'template': {
          'name': 'live_location_alert', // Template personalizado
          'language': {'code': 'es'},
          'components': [
            {
              'type': 'body',
              'parameters': [
                {'type': 'text', 'text': threatDescription},
                {'type': 'text', 'text': durationMinutes.toString()},
              ],
            },
            {
              'type': 'location',
              'parameters': [
                {
                  'type': 'location',
                  'location': {
                    'latitude': latitude,
                    'longitude': longitude,
                    'name': 'Ubicación SOS',
                    'address': 'Alerta de emergencia activa',
                  },
                },
              ],
            },
          ],
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Template de ubicación en tiempo real enviado a $to');
        return true;
      } else {
        debugPrint(
          '❌ Error enviando template: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error enviando template: $e');
      return false;
    }
  }

  // Enviar a múltiples contactos
  static Future<Map<String, bool>> sendToMultipleContacts({
    required List<String> phoneNumbers,
    required double latitude,
    required double longitude,
    required String threatDescription,
    required int durationMinutes,
  }) async {
    final results = <String, bool>{};

    for (final phoneNumber in phoneNumbers) {
      final success = await sendLiveLocationTemplate(
        to: phoneNumber,
        latitude: latitude,
        longitude: longitude,
        threatDescription: threatDescription,
        durationMinutes: durationMinutes,
      );
      results[phoneNumber] = success;

      // Pequeña pausa entre mensajes
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return results;
  }

  // Obtener información de la cuenta
  static Future<Map<String, dynamic>?> getAccountInfo() async {
    if (!isConfigured()) {
      return null;
    }

    try {
      final url = '$_baseUrl/$_businessAccountId';
      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error obteniendo información: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error obteniendo información: $e');
      return null;
    }
  }

  // Limpiar configuración
  static Future<void> clearConfiguration() async {
    try {
      _accessToken = null;
      _phoneNumberId = null;
      _businessAccountId = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('whatsapp_access_token');
      await prefs.remove('whatsapp_phone_number_id');
      await prefs.remove('whatsapp_business_account_id');

      debugPrint('✅ Configuración de WhatsApp Business API limpiada');
    } catch (e) {
      debugPrint('Error limpiando configuración: $e');
    }
  }
}
