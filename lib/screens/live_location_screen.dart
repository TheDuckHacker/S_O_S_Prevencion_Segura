import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sos_provider.dart';
import '../widgets/live_location_widget.dart';
import '../services/realtime_whatsapp_service.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Ubicación en Tiempo Real'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SosProvider>(
        builder: (context, sosProvider, child) {
          return FutureBuilder<bool>(
            future: RealtimeWhatsAppService.isSharingLocation(),
            builder: (context, snapshot) {
              final isSharing = snapshot.data ?? false;
              
              if (!isSharing) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No se está compartiendo ubicación',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Activa una alerta SOS para compartir tu ubicación en tiempo real',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Obtener coordenadas de la ubicación actual
              final locationParts = sosProvider.currentLocation.split(',');
              if (locationParts.length < 2) {
                return const Center(
                  child: Text('Error obteniendo ubicación'),
                );
              }

              final latitude = double.tryParse(locationParts[0].trim()) ?? 0.0;
              final longitude = double.tryParse(locationParts[1].split(' ')[0].trim()) ?? 0.0;

              // Calcular tiempo de finalización (60 minutos desde ahora)
              final endTime = DateTime.now().add(const Duration(minutes: 60));

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Widget principal de ubicación en tiempo real
                    LiveLocationWidget(
                      latitude: latitude,
                      longitude: longitude,
                      userName: 'Usuario',
                      userImage: '', // Puedes agregar una imagen de perfil
                      endTime: endTime,
                      onStopSharing: () => _stopLocationSharing(),
                      isSharing: isSharing,
                    ),
                    const SizedBox(height: 20),
                    // Información adicional
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Información de Compartir',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Ubicación actual',
                            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                            Icons.location_on,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Tiempo restante',
                            '${_getTimeRemaining(endTime)}',
                            Icons.access_time,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Estado',
                            'Compartiendo activamente',
                            Icons.check_circle,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Contactos',
                            'Enviando a contactos de emergencia',
                            Icons.people,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Botón para abrir en Google Maps
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openInGoogleMaps(latitude, longitude),
                        icon: const Icon(Icons.map),
                        label: const Text('Abrir en Google Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey.shade600,
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
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTimeRemaining(DateTime endTime) {
    final now = DateTime.now();
    final difference = endTime.difference(now);
    
    if (difference.isNegative) {
      return 'Finalizado';
    }
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Future<void> _stopLocationSharing() async {
    try {
      await RealtimeWhatsAppService.stopRealtimeLocationSharing();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación en tiempo real detenida'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deteniendo ubicación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openInGoogleMaps(double latitude, double longitude) async {
    try {
      final url = 'https://www.google.com/maps?q=$latitude,$longitude';
      // Aquí podrías usar url_launcher para abrir Google Maps
      debugPrint('Abrir en Google Maps: $url');
    } catch (e) {
      debugPrint('Error abriendo Google Maps: $e');
    }
  }
}
