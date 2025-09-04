import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Inicializar el servicio de notificaciones
  static Future<void> initialize() async {
    if (_initialized) return;

    // Configuración para Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  // Solicitar permisos de notificación
  static Future<bool> requestPermissions() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Mostrar notificación de alerta SOS
  static Future<void> showSosAlert({
    required String title,
    required String body,
    required String location,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'sos_channel',
          'Alertas SOS',
          channelDescription: 'Notificaciones de emergencia SOS',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1, // ID único
      title,
      body,
      details,
    );
  }

  // Mostrar notificación de ubicación compartida
  static Future<void> showLocationShared({
    required String contactName,
    required String location,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'location_channel',
          'Ubicación Compartida',
          channelDescription: 'Notificaciones de ubicación compartida',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      2,
      'Ubicación Compartida',
      'Tu ubicación ha sido compartida con $contactName',
      details,
    );
  }

  // Mostrar notificación de grabación iniciada
  static Future<void> showRecordingStarted() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'recording_channel',
          'Grabación de Evidencia',
          channelDescription: 'Notificaciones de grabación de evidencia',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          ongoing: true, // Notificación persistente
          enableVibration: true,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      3,
      'Grabación Iniciada',
      'Se está grabando evidencia de la situación',
      details,
    );
  }

  // Cancelar notificación de grabación
  static Future<void> cancelRecordingNotification() async {
    await _notifications.cancel(3);
  }

  // Mostrar notificación de progreso educativo
  static Future<void> showEducationProgress({
    required String lessonName,
    required int score,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'education_channel',
          'Progreso Educativo',
          channelDescription:
              'Notificaciones de progreso en el módulo educativo',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          showWhen: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      4,
      '¡Lección Completada!',
      'Has completado "$lessonName" con $score puntos',
      details,
    );
  }

  // Programar notificación de recordatorio
  static Future<void> scheduleReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'reminder_channel',
          'Recordatorios',
          channelDescription: 'Recordatorios de seguridad',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(5, title, body, details);
  }

  // Cancelar todas las notificaciones
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
