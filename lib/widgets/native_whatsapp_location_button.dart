import 'package:flutter/material.dart';
import '../services/native_location_sharing.dart';

class NativeWhatsAppLocationButton extends StatefulWidget {
  final String threatDescription;
  final String additionalText;
  final List<String> phoneNumbers;
  final int durationMinutes;

  const NativeWhatsAppLocationButton({
    super.key,
    required this.threatDescription,
    required this.additionalText,
    required this.phoneNumbers,
    this.durationMinutes = 60,
  });

  @override
  State<NativeWhatsAppLocationButton> createState() => _NativeWhatsAppLocationButtonState();
}

class _NativeWhatsAppLocationButtonState extends State<NativeWhatsAppLocationButton> {
  bool _isLoading = false;

  Future<void> _shareLiveLocation() async {
    if (widget.phoneNumbers.isEmpty) {
      _showSnackBar('No hay contactos de emergencia configurados', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await NativeLocationSharing.shareLiveLocation(
        phoneNumbers: widget.phoneNumbers,
        threatDescription: widget.threatDescription,
        durationMinutes: widget.durationMinutes,
      );

      if (success) {
        _showSnackBar('Ubicación en tiempo real compartida exitosamente');
      } else {
        _showSnackBar('Error compartiendo ubicación en tiempo real', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _shareLiveLocation,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.location_on, color: Colors.white, size: 24),
        label: Text(
          _isLoading
              ? 'Compartiendo ubicación...'
              : 'Compartir Ubicación en Tiempo Real',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
      ),
    );
  }
}
