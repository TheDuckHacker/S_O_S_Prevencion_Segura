import 'dart:async';
import 'package:flutter/material.dart';
import '../services/native_location_sharing.dart';
import '../services/realtime_whatsapp_service.dart';

class LiveLocationStatusWidget extends StatefulWidget {
  const LiveLocationStatusWidget({super.key});

  @override
  State<LiveLocationStatusWidget> createState() => _LiveLocationStatusWidgetState();
}

class _LiveLocationStatusWidgetState extends State<LiveLocationStatusWidget> {
  bool _isSharing = false;
  Map<String, dynamic>? _sharingInfo;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _checkSharingStatus();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkSharingStatus();
    });
  }

  Future<void> _checkSharingStatus() async {
    final isSharing = await RealtimeWhatsAppService.isSharingLocation();
    final sharingInfo = await NativeLocationSharing.getSharingInfo();
    
    if (mounted) {
      setState(() {
        _isSharing = isSharing;
        _sharingInfo = sharingInfo;
      });
    }
  }

  Future<void> _stopSharing() async {
    await RealtimeWhatsAppService.stopRealtimeLocationSharing();
    await _checkSharingStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSharing) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ubicación en Tiempo Real Activa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _stopSharing,
                icon: const Icon(Icons.stop, color: Colors.white),
                tooltip: 'Detener compartir ubicación',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Información de estado
          if (_sharingInfo != null) ...[
            _buildInfoRow(
              'Contactos',
              '${_sharingInfo!['successCount'] ?? 0}/${(_sharingInfo!['phoneNumbers'] as List?)?.length ?? 0}',
              Icons.people,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Duración',
              '${_sharingInfo!['durationMinutes'] ?? 0} minutos',
              Icons.access_time,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Estado',
              'Compartiendo activamente',
              Icons.check_circle,
            ),
          ] else ...[
            _buildInfoRow(
              'Estado',
              'Compartiendo activamente',
              Icons.check_circle,
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Botón para detener
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _stopSharing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade800,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Detener Compartir Ubicación',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
