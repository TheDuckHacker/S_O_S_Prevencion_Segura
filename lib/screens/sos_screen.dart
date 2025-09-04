import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sos_provider.dart';
import '../providers/location_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/whatsapp_alert_button.dart';
import '../services/realtime_whatsapp_service.dart';
import '../services/recording_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with TickerProviderStateMixin {
  late AnimationController _sosController;
  late AnimationController _recordingController;
  late Animation<double> _sosScaleAnimation;
  late Animation<double> _recordingRotationAnimation;

  final TextEditingController _threatController = TextEditingController();
  String _selectedThreatType = 'Me siguen';

  final List<String> _threatTypes = [
    'Me siguen',
    'Intento de secuestro',
    'Acoso',
    'Situación sospechosa',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();

    // Controlador para la animación del botón SOS
    _sosController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Controlador para la animación de grabación
    _recordingController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _sosScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _sosController, curve: Curves.easeInOut));

    _recordingRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _recordingController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _sosController.dispose();
    _recordingController.dispose();
    _threatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header con botón de regreso
              _buildHeader(),

              // Contenido principal
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Botón SOS principal
                      _buildMainSosButton(),

                      const SizedBox(height: 30),

                      // Descripción de la amenaza
                      _buildThreatDescription(),

                      const SizedBox(height: 30),

                      // Botones de acción rápida
                      _buildQuickActions(),

                      const SizedBox(height: 30),

                      // Estado de la alerta
                      _buildAlertStatus(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Text(
            'Alerta de Emergencia',
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSosButton() {
    return Consumer<SosProvider>(
      builder: (context, sosProvider, child) {
        bool isSosActive = sosProvider.isSosActive;

        return GestureDetector(
          onTapDown: (_) => _sosController.forward(),
          onTapUp: (_) => _sosController.reverse(),
          onTapCancel: () => _sosController.reverse(),
          onTap: () => _handleSosActivation(sosProvider),
          child: AnimatedBuilder(
            animation: _sosScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _sosScaleAnimation.value,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient:
                        isSosActive
                            ? AppColors.dangerRed
                                    .withOpacity(0.8)
                                    .toString()
                                    .contains('gradient')
                                ? AppColors.sosGradient
                                : LinearGradient(
                                  colors: [
                                    AppColors.dangerRed,
                                    AppColors.dangerRed,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                            : AppColors.sosGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            isSosActive
                                ? AppColors.dangerRed.withOpacity(0.6)
                                : AppColors.sosRed.withOpacity(0.4),
                        blurRadius: isSosActive ? 30 : 20,
                        spreadRadius: isSosActive ? 10 : 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSosActive ? Icons.stop : Icons.emergency,
                          color: Colors.white,
                          size: 80,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          isSosActive ? 'DESACTIVAR' : 'ACTIVAR SOS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isSosActive) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ALERTA ACTIVA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildThreatDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción de la Amenaza',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),

          // Dropdown para tipo de amenaza
          DropdownButtonFormField<String>(
            value: _selectedThreatType,
            decoration: InputDecoration(
              labelText: 'Tipo de amenaza',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
            ),
            dropdownColor: AppColors.surfaceColor,
            style: const TextStyle(color: Colors.white),
            items:
                _threatTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedThreatType = newValue!;
              });
            },
          ),

          const SizedBox(height: 15),

          // Campo de texto para descripción adicional
          TextField(
            controller: _threatController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descripción adicional (opcional)',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
            ),
            style: const TextStyle(color: Colors.white),
          ),

          // Botón para actualizar descripción cuando SOS esté activo
          Consumer<SosProvider>(
            builder: (context, sosProvider, child) {
              if (sosProvider.isSosActive &&
                  _threatController.text.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _updateDescription(sosProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Actualizar Descripción',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Consumer<SosProvider>(
      builder: (context, sosProvider, child) {
        bool isSosActive = sosProvider.isSosActive;

        return Column(
          children: [
            Row(
              children: [
                // Botón de grabación
                Expanded(
                  child: _buildActionButton(
                    icon:
                        sosProvider.isRecording
                            ? Icons.stop
                            : Icons.fiber_manual_record,
                    label: sosProvider.isRecording 
                        ? 'Detener' 
                        : (sosProvider.isSosActive ? 'Grabar' : 'Activa SOS'),
                    gradient:
                        sosProvider.isRecording
                            ? AppColors.dangerRed.toString().contains(
                                  'gradient',
                                )
                                ? AppColors.safeGradient
                                : LinearGradient(
                                  colors: [
                                    AppColors.dangerRed,
                                    AppColors.dangerRed,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                            : (sosProvider.isSosActive 
                                ? AppColors.safeGradient 
                                : LinearGradient(
                                    colors: [Colors.grey, Colors.grey.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )),
                    onTap: sosProvider.isSosActive 
                        ? () => _handleRecording(sosProvider)
                        : () => _showMessage('Primero activa la alerta SOS'),
                    isActive: sosProvider.isRecording,
                  ),
                ),

                const SizedBox(width: 15),

                // Botón de ubicación
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.location_on,
                    label: 'Ubicación',
                    gradient: AppColors.safeGradient,
                    onTap: () => _showLocationInfo(),
                    isActive: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Botón de información de almacenamiento
            SizedBox(
              width: double.infinity,
              child: _buildActionButton(
                icon: Icons.folder_open,
                label: 'Ver Grabaciones Guardadas',
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _showStorageInfo(),
                isActive: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertStatus() {
    return Consumer<SosProvider>(
      builder: (context, sosProvider, child) {
        if (!sosProvider.isSosActive) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 40),
                const SizedBox(height: 10),
                Text(
                  'Alerta SOS inactiva',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  'Toca el botón SOS para activar la alerta de emergencia',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.dangerRed.withOpacity(0.8),
                AppColors.sosOrange.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'ALERTA SOS ACTIVA',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Ubicación: ${sosProvider.currentLocation}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Descripción: ${sosProvider.threatDescription}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                'La alerta ha sido enviada a tus contactos de confianza',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón para compartir ubicación manualmente
                  GestureDetector(
                    onTap: () => _shareLocationManually(sosProvider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share_location,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Compartir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botón para abrir permisos de ubicación
                  GestureDetector(
                    onTap: () => _openLocationPermissions(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Permisos',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Botón de WhatsApp para enviar alerta
              WhatsAppAlertButton(
                threatDescription: sosProvider.threatDescription,
                additionalText: _threatController.text,
                latitude: _getLatitudeFromLocation(sosProvider.currentLocation),
                longitude: _getLongitudeFromLocation(
                  sosProvider.currentLocation,
                ),
              ),
              const SizedBox(height: 15),
              // Botón para detener compartir ubicación en tiempo real
              _buildStopLocationSharingButton(),
            ],
          ),
        );
      },
    );
  }

  void _handleSosActivation(SosProvider sosProvider) {
    if (sosProvider.isSosActive) {
      // Desactivar SOS
      sosProvider.deactivateSos();
      _showMessage('Alerta SOS desactivada');
    } else {
      // Activar SOS
      String description =
          _threatController.text.isNotEmpty
              ? '$_selectedThreatType: ${_threatController.text}'
              : _selectedThreatType;

      sosProvider.updateThreatDescription(description);
      sosProvider.activateSos();
      _showMessage('Alerta SOS activada');
    }
  }

  void _handleRecording(SosProvider sosProvider) async {
    if (sosProvider.isRecording) {
      sosProvider.stopRecording();
      _recordingController.stop();
      _showMessage('Grabación detenida');
    } else {
      // Solo permitir grabación si SOS está activo
      if (!sosProvider.isSosActive) {
        _showMessage('Primero activa la alerta SOS para poder grabar');
        return;
      }

      // Verificar si la cámara está disponible antes de iniciar
      if (!RecordingService.isCameraAvailable()) {
        _showMessage('Inicializando cámara...');
        await RecordingService.initializeCamera();

        if (!RecordingService.isCameraAvailable()) {
          _showMessage(
            '❌ No se pudo acceder a la cámara. Verifica los permisos.',
          );
          return;
        }
      }

      sosProvider.startRecording();
      _recordingController.repeat();
      _showMessage('Grabación iniciada');
    }
  }

  void _showLocationInfo() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Información de Ubicación',
              style: TextStyle(color: Colors.white),
            ),
            content: Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado: ${locationProvider.locationStatus}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    if (locationProvider.currentPosition != null) ...[
                      Text(
                        'Latitud: ${locationProvider.currentPosition!.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Longitud: ${locationProvider.currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: AppColors.lightBlue),
                ),
              ),
            ],
          ),
    );
  }

  void _shareLocationManually(SosProvider sosProvider) async {
    try {
      await sosProvider.shareLocationViaWhatsApp();
      _showMessage('Ubicación compartida por WhatsApp');
    } catch (e) {
      _showMessage('Error compartiendo ubicación: $e');
    }
  }

  void _openLocationPermissions() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      await locationProvider.requestLocationPermission();
      _showMessage('Permisos de ubicación solicitados');
    } catch (e) {
      _showMessage('Error solicitando permisos: $e');
    }
  }

  void _updateDescription(SosProvider sosProvider) {
    if (_threatController.text.isNotEmpty) {
      final newDescription = '$_selectedThreatType: ${_threatController.text}';
      sosProvider.updateThreatDescription(newDescription);
      _showMessage('Descripción actualizada');
    } else {
      _showMessage('Por favor escribe una descripción');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getLatitudeFromLocation(String location) {
    try {
      // Formato esperado: "lat, lng (Precisión: X.Xm)"
      final parts = location.split(',');
      if (parts.isNotEmpty) {
        return parts[0].trim();
      }
    } catch (e) {
      debugPrint('Error extrayendo latitud: $e');
    }
    return '0.0';
  }

  String _getLongitudeFromLocation(String location) {
    try {
      // Formato esperado: "lat, lng (Precisión: X.Xm)"
      final parts = location.split(',');
      if (parts.length >= 2) {
        // Remover la parte de precisión si existe
        final lngPart = parts[1].trim();
        final lngParts = lngPart.split(' ');
        return lngParts[0].trim();
      }
    } catch (e) {
      debugPrint('Error extrayendo longitud: $e');
    }
    return '0.0';
  }

  Widget _buildStopLocationSharingButton() {
    return FutureBuilder<bool>(
      future: RealtimeWhatsAppService.isSharingLocation(),
      builder: (context, snapshot) {
        final isSharing = snapshot.data ?? false;

        if (!isSharing) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () => _stopLocationSharing(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Detener Compartir Ubicación',
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
      },
    );
  }

  Future<void> _stopLocationSharing() async {
    try {
      await RealtimeWhatsAppService.stopRealtimeLocationSharing();
      _showMessage('Compartir ubicación en tiempo real detenido');
    } catch (e) {
      _showMessage('Error deteniendo compartir ubicación: $e');
    }
  }

  void _showStorageInfo() {
    RecordingService.showStorageInfo(context);
  }
}
