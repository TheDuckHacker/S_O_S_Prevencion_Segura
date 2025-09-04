import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sos_provider.dart';
import '../providers/education_provider.dart';
import '../utils/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
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

              // Tabs de navegación
              _buildTabBar(),

              // Contenido de los tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSosHistoryTab(),
                    _buildEducationHistoryTab(),
                  ],
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
            'Historial y Progreso',
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.safeGradient,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [Tab(text: 'Alertas SOS'), Tab(text: 'Educación')],
      ),
    );
  }

  Widget _buildSosHistoryTab() {
    return Consumer<SosProvider>(
      builder: (context, sosProvider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Resumen de alertas
                _buildSosSummary(sosProvider),

                const SizedBox(height: 30),

                // Lista de alertas
                _buildSosHistoryList(sosProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSosSummary(SosProvider sosProvider) {
    final totalAlerts = sosProvider.sosHistory.length;
    final activeAlerts =
        sosProvider.sosHistory
            .where((alert) => alert['status'] == 'active')
            .length;
    final resolvedAlerts =
        sosProvider.sosHistory
            .where((alert) => alert['status'] == 'resolved')
            .length;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.history, color: AppColors.lightGreen, size: 50),
          const SizedBox(height: 20),

          Text(
            'Resumen de Alertas SOS',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryCard(
                'Total',
                totalAlerts.toString(),
                Icons.emergency,
                AppColors.primaryBlue,
              ),
              _buildSummaryCard(
                'Activas',
                activeAlerts.toString(),
                Icons.warning,
                AppColors.sosRed,
              ),
              _buildSummaryCard(
                'Resueltas',
                resolvedAlerts.toString(),
                Icons.check_circle,
                AppColors.lightGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSosHistoryList(SosProvider sosProvider) {
    if (sosProvider.sosHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.history, color: Colors.white70, size: 50),
            const SizedBox(height: 20),
            Text(
              'Sin historial de alertas',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              'Las alertas SOS aparecerán aquí cuando las actives',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de Alertas',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),

        ...sosProvider.sosHistory
            .map((alert) => _buildSosAlertCard(alert))
            .toList(),
      ],
    );
  }

  Widget _buildSosAlertCard(Map<String, dynamic> alert) {
    final isActive = alert['status'] == 'active';
    final timestamp = DateTime.parse(alert['timestamp']);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            isActive
                ? LinearGradient(
                  colors: [
                    AppColors.sosRed.withOpacity(0.2),
                    AppColors.sosOrange.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isActive
                  ? AppColors.sosRed.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.warning : Icons.check_circle,
                color: isActive ? AppColors.sosRed : AppColors.lightGreen,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isActive ? 'ALERTA ACTIVA' : 'ALERTA RESUELTA',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.sosRed : AppColors.lightGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _formatTimestamp(timestamp),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            'Descripción:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            alert['description'] ?? 'Sin descripción',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),

          const SizedBox(height: 10),

          Text(
            'Ubicación:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            alert['location'] ?? 'Ubicación no disponible',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),

          if (alert['resolvedAt'] != null) ...[
            const SizedBox(height: 10),
            Text(
              'Resuelta:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _formatTimestamp(DateTime.parse(alert['resolvedAt'])),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationHistoryTab() {
    return Consumer<EducationProvider>(
      builder: (context, educationProvider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Resumen educativo
                _buildEducationSummary(educationProvider),

                const SizedBox(height: 30),

                // Historial de respuestas
                _buildEducationHistoryList(educationProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationSummary(EducationProvider educationProvider) {
    final progress = educationProvider.getUserProgressPercentage();
    final totalScore = educationProvider.totalScore;
    final completedScenarios = educationProvider.userProgress.length;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.school, color: AppColors.lightGreen, size: 50),
          const SizedBox(height: 20),

          Text(
            'Resumen Educativo',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryCard(
                'Progreso',
                '${progress.toInt()}%',
                Icons.trending_up,
                AppColors.lightGreen,
              ),
              _buildSummaryCard(
                'Puntos',
                totalScore.toString(),
                Icons.stars,
                AppColors.infoBlue,
              ),
              _buildSummaryCard(
                'Completados',
                completedScenarios.toString(),
                Icons.check_circle,
                AppColors.primaryPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationHistoryList(EducationProvider educationProvider) {
    if (educationProvider.userProgress.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.school, color: Colors.white70, size: 50),
            const SizedBox(height: 20),
            Text(
              'Sin historial educativo',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              'Completa escenarios para ver tu historial',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historial de Respuestas',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),

        ...educationProvider.userProgress.take(10).map((progress) {
          final scenario = educationProvider.interactiveScenarios.firstWhere(
            (s) => s['id'] == progress['scenarioId'],
            orElse: () => {},
          );

          if (scenario.isEmpty) return const SizedBox.shrink();

          return _buildEducationProgressCard(progress, scenario);
        }).toList(),
      ],
    );
  }

  Widget _buildEducationProgressCard(
    Map<String, dynamic> progress,
    Map<String, dynamic> scenario,
  ) {
    final isCorrect = progress['isCorrect'];
    final timestamp = DateTime.parse(progress['timestamp']);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isCorrect
                  ? AppColors.lightGreen.withOpacity(0.3)
                  : AppColors.sosRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? AppColors.lightGreen : AppColors.sosRed,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  scenario['question'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${progress['points']} pts',
                  style: TextStyle(
                    color: isCorrect ? AppColors.lightGreen : AppColors.sosRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Respondido: ${_formatTimestamp(timestamp)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Ahora';
    }
  }
}
