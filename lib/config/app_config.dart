class AppConfig {
  // Configuración para diferentes entornos
  static const String _environment =
      'production'; // 'development', 'staging', 'production'

  // URLs de servidor según el entorno
  static const Map<String, String> _serverUrls = {
    'development': 'http://192.168.0.131:3000/api', // Tu IP local
    'staging':
        'https://prevencion-segura-staging.up.railway.app/api', // Railway
    'production':
        'https://s-o-s-prevencion-segura.onrender.com/api', // Render (gratis)
  };

  // Obtener URL del servidor según el entorno
  static String get serverUrl =>
      _serverUrls[_environment] ?? _serverUrls['development']!;

  // Configuración de la aplicación
  static const String appName = 'Prevención Segura';
  static const String appVersion = '2.0.0';

  // Configuración de WhatsApp
  static const String whatsAppSupport = '+59112345678'; // Tu número de soporte

  // Configuración de notificaciones
  static const int maxNotificationRetries = 3;
  static const Duration notificationTimeout = Duration(seconds: 30);

  // Configuración de grabación
  static const int maxRecordingDuration = 300; // 5 minutos en segundos
  static const int maxFileSize = 50 * 1024 * 1024; // 50 MB

  // Configuración de ubicación
  static const double locationAccuracy = 10.0; // metros
  static const Duration locationTimeout = Duration(seconds: 10);

  // Configuración de seguridad
  static const bool enableEncryption = true;
  static const bool enableLogging = true;

  // Obtener configuración de desarrollo
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';

  // Configuración de debug
  static bool get enableDebugMode => isDevelopment;
}
