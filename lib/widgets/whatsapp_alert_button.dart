import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppAlertButton extends StatelessWidget {
  final String threatDescription;
  final String additionalText;
  final String latitude;
  final String longitude;
  final String? phoneNumber;

  const WhatsAppAlertButton({
    super.key,
    required this.threatDescription,
    required this.additionalText,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF128C7E)], // Colores de WhatsApp
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _sendWhatsAppAlert(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.message, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Enviar Alerta por WhatsApp',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendWhatsAppAlert(BuildContext context) async {
    try {
      // Crear el mensaje de alerta
      final alertMessage = _createAlertMessage();

      // Crear la URL de WhatsApp
      final whatsappUrl = _createWhatsAppUrl(alertMessage);

      // Intentar abrir WhatsApp
      final uri = Uri.parse(whatsappUrl);

      // Intentar abrir WhatsApp directamente
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Mostrar confirmación
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('WhatsApp abierto con el mensaje de alerta'),
                ],
              ),
              backgroundColor: const Color(0xFF25D366),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        // Si hay error, mostrar mensaje pero no el diálogo
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Error abriendo WhatsApp: $e')),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error abriendo WhatsApp: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Error al abrir WhatsApp: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String _createAlertMessage() {
    final googleMapsUrl = 'https://maps.google.com/?q=$latitude,$longitude';

    return '''🚨 ALERTA SOS ACTIVA 🚨

Descripción: $threatDescription${additionalText.isNotEmpty ? ' - $additionalText' : ''}

📍 Ubicación: $googleMapsUrl

⏰ Hora: ${DateTime.now().toString()}

🔗 Ver ubicación en Google Maps: $googleMapsUrl

*Esta alerta fue enviada desde la app Prevención Segura*''';
  }

  String _createWhatsAppUrl(String message) {
    final encodedMessage = Uri.encodeComponent(message);

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      // Enviar a un número específico
      return 'https://wa.me/$phoneNumber?text=$encodedMessage';
    } else {
      // Abrir WhatsApp sin número específico (usuario elige contacto)
      return 'https://wa.me/?text=$encodedMessage';
    }
  }

  void _showWhatsAppNotInstalledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.message, color: const Color(0xFF25D366), size: 30),
              const SizedBox(width: 10),
              const Text('WhatsApp no encontrado'),
            ],
          ),
          content: const Text(
            'WhatsApp no está instalado en tu dispositivo. '
            'Por favor instala WhatsApp desde la Play Store para poder enviar alertas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openPlayStore(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Instalar WhatsApp'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openPlayStore(BuildContext context) async {
    try {
      const playStoreUrl =
          'https://play.google.com/store/apps/details?id=com.whatsapp';
      final uri = Uri.parse(playStoreUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir la Play Store'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error abriendo Play Store: $e');
    }
  }
}

// Widget compacto para usar en espacios pequeños
class WhatsAppAlertButtonCompact extends StatelessWidget {
  final String threatDescription;
  final String additionalText;
  final String latitude;
  final String longitude;
  final String? phoneNumber;

  const WhatsAppAlertButtonCompact({
    super.key,
    required this.threatDescription,
    required this.additionalText,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF25D366), Color(0xFF128C7E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25D366).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => _sendWhatsAppAlert(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.message, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'WhatsApp',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendWhatsAppAlert(BuildContext context) async {
    try {
      final alertMessage = _createAlertMessage();
      final whatsappUrl = _createWhatsAppUrl(alertMessage);
      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('WhatsApp abierto'),
                ],
              ),
              backgroundColor: const Color(0xFF25D366),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 10),
                  Text('WhatsApp no está instalado'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error abriendo WhatsApp: $e');
    }
  }

  String _createAlertMessage() {
    final googleMapsUrl = 'https://maps.google.com/?q=$latitude,$longitude';

    return '''🚨 ALERTA SOS ACTIVA 🚨

Descripción: $threatDescription${additionalText.isNotEmpty ? ' - $additionalText' : ''}

📍 Ubicación: $googleMapsUrl

⏰ Hora: ${DateTime.now().toString()}

🔗 Ver ubicación en Google Maps: $googleMapsUrl

*Esta alerta fue enviada desde la app Prevención Segura*''';
  }

  String _createWhatsAppUrl(String message) {
    final encodedMessage = Uri.encodeComponent(message);

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      return 'https://wa.me/$phoneNumber?text=$encodedMessage';
    } else {
      return 'https://wa.me/?text=$encodedMessage';
    }
  }
}
