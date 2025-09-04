import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/sos_provider.dart';
import '../utils/app_colors.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isSharingLocation = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
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
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Mapa simulado
                        _buildMapSection(),

                        const SizedBox(height: 30),

                        // Información de ubicación
                        _buildLocationInfo(),

                        const SizedBox(height: 30),

                        // Acciones de ubicación
                        _buildLocationActions(),

                        const SizedBox(height: 30),

                        // Estadísticas de ubicación
                        _buildLocationStats(),
                      ],
                    ),
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
            'Mapa y Ubicación',
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Stack(
        children: [
          // Mapa simulado
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: AppColors.surfaceColor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, color: Colors.white70, size: 60),
                  const SizedBox(height: 15),
                  Text(
                    'Mapa en Tiempo Real',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Aquí se mostraría el mapa real',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Indicador de ubicación actual
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightGreen.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),

          // Estado de ubicación
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        locationProvider.hasLocationPermission
                            ? Icons.location_on
                            : Icons.location_off,
                        color:
                            locationProvider.hasLocationPermission
                                ? AppColors.lightGreen
                                : AppColors.sosRed,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          locationProvider.locationStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.lightBlue,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Información de Ubicación',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (locationProvider.currentPosition != null) ...[
                _buildLocationDetail(
                  'Latitud',
                  locationProvider.currentPosition!.latitude.toStringAsFixed(6),
                  Icons.explore,
                ),
                const SizedBox(height: 15),
                _buildLocationDetail(
                  'Longitud',
                  locationProvider.currentPosition!.longitude.toStringAsFixed(
                    6,
                  ),
                  Icons.explore,
                ),
                const SizedBox(height: 15),
                _buildLocationDetail(
                  'Precisión',
                  '${locationProvider.currentPosition!.accuracy.toStringAsFixed(1)}m',
                  Icons.gps_fixed,
                ),
                const SizedBox(height: 15),
                _buildLocationDetail(
                  'Altitud',
                  locationProvider.currentPosition!.altitude > 0
                      ? '${locationProvider.currentPosition!.altitude.toStringAsFixed(1)}m'
                      : 'No disponible',
                  Icons.height,
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.location_off, color: Colors.white70, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'Ubicación no disponible',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Verifica los permisos de ubicación',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.lightBlue, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationActions() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones de Ubicación',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // Botón de actualizar ubicación
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Actualizar',
                    gradient: AppColors.safeGradient,
                    onTap: () => _updateLocation(locationProvider),
                  ),
                ),

                const SizedBox(width: 15),

                // Botón de compartir ubicación
                Expanded(
                  child: _buildActionButton(
                    icon:
                        _isSharingLocation ? Icons.stop : Icons.share_location,
                    label: _isSharingLocation ? 'Detener' : 'Compartir',
                    gradient:
                        _isSharingLocation
                            ? AppColors.sosGradient
                            : AppColors.safeGradient,
                    onTap: () => _toggleLocationSharing(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Botón de permisos
            if (!locationProvider.hasLocationPermission)
              _buildActionButton(
                icon: Icons.location_on,
                label: 'Solicitar Permisos',
                gradient: AppColors.safeGradient,
                onTap: () => _requestLocationPermission(locationProvider),
                isFullWidth: true,
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
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: isFullWidth ? double.infinity : null,
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

  Widget _buildLocationStats() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final stats = locationProvider.getLocationStats();

        return Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.analytics, color: AppColors.lightGreen, size: 30),
                  const SizedBox(width: 15),
                  Text(
                    'Estadísticas de Ubicación',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    'Ubicaciones',
                    stats['totalLocations'].toString(),
                    Icons.location_on,
                    AppColors.primaryBlue,
                  ),
                  _buildStatCard(
                    'Distancia',
                    '${(stats['totalDistance'] / 1000).toStringAsFixed(1)}km',
                    Icons.straighten,
                    AppColors.lightGreen,
                  ),
                  _buildStatCard(
                    'Velocidad',
                    '${stats['averageSpeed'].toStringAsFixed(1)}m/s',
                    Icons.speed,
                    AppColors.infoBlue,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed:
                    stats['totalLocations'] > 0
                        ? () => _clearLocationHistory(locationProvider)
                        : null,
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar Historial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sosRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  void _updateLocation(LocationProvider locationProvider) {
    locationProvider.updateLocation();
    _showMessage('Ubicación actualizada');
  }

  void _toggleLocationSharing() {
    setState(() {
      _isSharingLocation = !_isSharingLocation;
    });

    if (_isSharingLocation) {
      _showMessage('Compartiendo ubicación en tiempo real');
      // Aquí se implementaría la lógica real de compartir ubicación
    } else {
      _showMessage('Compartir ubicación detenido');
    }
  }

  void _requestLocationPermission(LocationProvider locationProvider) {
    locationProvider.requestLocationPermission();
    _showMessage('Solicitando permisos de ubicación');
  }

  void _clearLocationHistory(LocationProvider locationProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text(
              'Limpiar Historial',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '¿Estás seguro de que quieres limpiar todo el historial de ubicaciones? Esta acción no se puede deshacer.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: AppColors.lightBlue),
                ),
              ),
              TextButton(
                onPressed: () {
                  locationProvider.clearLocationHistory();
                  Navigator.pop(context);
                  _showMessage('Historial de ubicaciones limpiado');
                },
                child: const Text(
                  'Limpiar',
                  style: TextStyle(color: AppColors.sosRed),
                ),
              ),
            ],
          ),
    );
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
}
