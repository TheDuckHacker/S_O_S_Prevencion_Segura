import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/education_provider.dart';
import '../utils/app_colors.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _selectedTipIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
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
                    _buildTipsTab(),
                    _buildInteractiveTab(),
                    _buildProgressTab(),
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
            'Prevención y Educación',
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
        tabs: const [
          Tab(text: 'Consejos'),
          Tab(text: 'Simulador'),
          Tab(text: 'Progreso'),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return Consumer<EducationProvider>(
      builder: (context, educationProvider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Consejo destacado
                _buildFeaturedTip(educationProvider),

                const SizedBox(height: 30),

                // Lista de consejos por categoría
                _buildTipsByCategory(educationProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedTip(EducationProvider educationProvider) {
    if (educationProvider.preventionTips.isEmpty)
      return const SizedBox.shrink();

    final tip = educationProvider.preventionTips[_selectedTipIndex];

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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tip['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(tip['icon'], color: tip['color'], size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tip['difficulty'].toString().toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tip['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            tip['content'],
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.5),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Navegación entre consejos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed:
                    _selectedTipIndex > 0
                        ? () => setState(() => _selectedTipIndex--)
                        : null,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: _selectedTipIndex > 0 ? Colors.white : Colors.white30,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedTipIndex + 1} de ${educationProvider.preventionTips.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                onPressed:
                    _selectedTipIndex <
                            educationProvider.preventionTips.length - 1
                        ? () => setState(() => _selectedTipIndex++)
                        : null,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color:
                      _selectedTipIndex <
                              educationProvider.preventionTips.length - 1
                          ? Colors.white
                          : Colors.white30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsByCategory(EducationProvider educationProvider) {
    final categories = [
      'riesgo',
      'seguridad',
      'comunicación',
      'preparación',
      'planificación',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consejos por Categoría',
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        ...categories.map((category) {
          final tips = educationProvider.getTipsByCategory(category);
          if (tips.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCategoryDisplayName(category),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightGreen,
                ),
              ),
              const SizedBox(height: 10),

              ...tips.map((tip) => _buildTipCard(tip)),

              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tip['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip['icon'], color: tip['color'], size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip['title'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(
                  tip['content'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveTab() {
    return Consumer<EducationProvider>(
      builder: (context, educationProvider, child) {
        final currentScenario = educationProvider.getCurrentScenario();

        if (currentScenario == null) {
          return const Center(
            child: Text(
              'No hay escenarios disponibles',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Escenario actual
                _buildScenarioCard(currentScenario),

                const SizedBox(height: 30),

                // Opciones de respuesta
                _buildAnswerOptions(educationProvider, currentScenario),

                const SizedBox(height: 30),

                // Explicación (si se ha respondido)
                if (_showExplanation) _buildExplanation(currentScenario),

                const SizedBox(height: 30),

                // Navegación entre escenarios
                _buildScenarioNavigation(educationProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScenarioCard(Map<String, dynamic> scenario) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.quiz, color: AppColors.lightGreen, size: 50),
          const SizedBox(height: 20),

          Text(
            'Escenario ${scenario['id']}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.lightGreen,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            scenario['question'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: _getDifficultyColor(
                scenario['difficulty'],
              ).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              scenario['difficulty'].toString().toUpperCase(),
              style: TextStyle(
                color: _getDifficultyColor(scenario['difficulty']),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(
    EducationProvider educationProvider,
    Map<String, dynamic> scenario,
  ) {
    return Column(
      children: [
        Text(
          'Selecciona la mejor respuesta:',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),

        ...List.generate(scenario['options'].length, (index) {
          final option = scenario['options'][index];
          final isSelected = _selectedAnswer == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: GestureDetector(
              onTap: () => setState(() => _selectedAnswer = index),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? AppColors.safeGradient
                          : AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white70,
                          width: 2,
                        ),
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                              : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed:
              _selectedAnswer != null
                  ? () => _submitAnswer(educationProvider, scenario)
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Responder',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation(Map<String, dynamic> scenario) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightGreen.withOpacity(0.2),
            AppColors.infoBlue.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.lightGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.lightGreen, size: 24),
              const SizedBox(width: 10),
              Text(
                'Explicación',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            scenario['explanation'],
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioNavigation(EducationProvider educationProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed:
              educationProvider.currentLessonIndex > 0
                  ? () => educationProvider.previousScenario()
                  : null,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Anterior'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${educationProvider.currentLessonIndex + 1} de ${educationProvider.interactiveScenarios.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        ElevatedButton.icon(
          onPressed:
              educationProvider.currentLessonIndex <
                      educationProvider.interactiveScenarios.length - 1
                  ? () => educationProvider.nextScenario()
                  : null,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Siguiente'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTab() {
    return Consumer<EducationProvider>(
      builder: (context, educationProvider, child) {
        final progress = educationProvider.getUserProgressPercentage();
        final scores = educationProvider.getScoreByDifficulty();

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Progreso general
                _buildGeneralProgress(progress, educationProvider.totalScore),

                const SizedBox(height: 30),

                // Puntuación por dificultad
                _buildDifficultyScores(scores),

                const SizedBox(height: 30),

                // Historial de respuestas
                _buildAnswerHistory(educationProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneralProgress(double progress, num totalScore) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.trending_up, color: AppColors.lightGreen, size: 50),
          const SizedBox(height: 20),

          Text(
            'Progreso General',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.lightGreen,
                  ),
                ),
              ),
              Text(
                '${progress.toInt()}%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            'Puntuación Total: $totalScore puntos',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.lightGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyScores(Map<String, num> scores) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Puntuación por Dificultad',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),

        ...scores.entries.map((entry) {
          final difficulty = entry.key;
          final score = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDifficultyIcon(difficulty),
                    color: _getDifficultyColor(difficulty),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDifficultyDisplayName(difficulty),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$score puntos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAnswerHistory(EducationProvider educationProvider) {
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
            Icon(Icons.history, color: Colors.white70, size: 50),
            const SizedBox(height: 20),
            Text(
              'Sin historial',
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

        ...educationProvider.userProgress.take(5).map((progress) {
          final scenario = educationProvider.interactiveScenarios.firstWhere(
            (s) => s['id'] == progress['scenarioId'],
            orElse: () => {},
          );

          if (scenario.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    progress['isCorrect']
                        ? AppColors.lightGreen.withOpacity(0.3)
                        : AppColors.sosRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  progress['isCorrect'] ? Icons.check_circle : Icons.cancel,
                  color:
                      progress['isCorrect']
                          ? AppColors.lightGreen
                          : AppColors.sosRed,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario['question'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${progress['points']} puntos • ${_formatTimestamp(progress['timestamp'])}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _submitAnswer(
    EducationProvider educationProvider,
    Map<String, dynamic> scenario,
  ) {
    if (_selectedAnswer != null) {
      educationProvider.answerScenario(scenario['id'], _selectedAnswer!);
      setState(() {
        _showExplanation = true;
      });

      // Resetear selección después de un delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _selectedAnswer = null;
            _showExplanation = false;
          });
        }
      });
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'riesgo':
        return 'Señales de Riesgo';
      case 'seguridad':
        return 'Situaciones Seguras';
      case 'comunicación':
        return 'Comunicación Segura';
      case 'preparación':
        return 'Preparación';
      case 'planificación':
        return 'Planificación';
      default:
        return category;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'básico':
        return AppColors.lightGreen;
      case 'intermedio':
        return AppColors.infoBlue;
      case 'avanzado':
        return AppColors.primaryPurple;
      default:
        return AppColors.lightGreen;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'básico':
        return Icons.star;
      case 'intermedio':
        return Icons.star_half;
      case 'avanzado':
        return Icons.stars;
      default:
        return Icons.star;
    }
  }

  String _getDifficultyDisplayName(String difficulty) {
    switch (difficulty) {
      case 'básico':
        return 'Nivel Básico';
      case 'intermedio':
        return 'Nivel Intermedio';
      case 'avanzado':
        return 'Nivel Avanzado';
      default:
        return difficulty;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return timestamp;
    }
  }
}
