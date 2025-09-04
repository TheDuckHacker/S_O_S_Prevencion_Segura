import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EducationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _preventionTips = [];
  List<Map<String, dynamic>> _interactiveScenarios = [];
  List<Map<String, dynamic>> _userProgress = [];
  int _currentLessonIndex = 0;
  num _totalScore = 0;

  // Getters
  List<Map<String, dynamic>> get preventionTips => _preventionTips;
  List<Map<String, dynamic>> get interactiveScenarios => _interactiveScenarios;
  List<Map<String, dynamic>> get userProgress => _userProgress;
  int get currentLessonIndex => _currentLessonIndex;
  num get totalScore => _totalScore;

  EducationProvider() {
    _initializeContent();
  }

  // Inicializar contenido educativo
  void _initializeContent() {
    _preventionTips = [
      {
        'id': 1,
        'title': 'Señales de Riesgo',
        'content':
            'Desconfía si alguien te pide ir a un lugar desconocido solo/a',
        'category': 'riesgo',
        'difficulty': 'básico',
        'icon': Icons.warning,
        'color': Colors.orange,
      },
      {
        'id': 2,
        'title': 'Situaciones Seguras',
        'content': 'Siempre avisa a un familiar sobre tus rutas y horarios',
        'category': 'seguridad',
        'difficulty': 'básico',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'id': 3,
        'title': 'Comunicación Segura',
        'content':
            'Usa códigos secretos con tu familia para situaciones de emergencia',
        'category': 'comunicación',
        'difficulty': 'intermedio',
        'icon': Icons.message,
        'color': Colors.blue,
      },
      {
        'id': 4,
        'title': 'Awareness del Entorno',
        'content': 'Mantén tu teléfono cargado y con datos activos',
        'category': 'preparación',
        'difficulty': 'básico',
        'icon': Icons.phone_android,
        'color': Colors.purple,
      },
      {
        'id': 5,
        'title': 'Rutas Alternativas',
        'content': 'Conoce múltiples rutas para llegar a casa',
        'category': 'planificación',
        'difficulty': 'intermedio',
        'icon': Icons.map,
        'color': Colors.teal,
      },
    ];

    _interactiveScenarios = [
      {
        'id': 1,
        'question': '¿Qué harías si alguien te sigue?',
        'options': [
          'Correr hacia un lugar público',
          'Ignorar y seguir caminando',
          'Confrontar a la persona',
          'Llamar a emergencias inmediatamente',
        ],
        'correctAnswer': 0,
        'explanation':
            'La mejor opción es dirigirte a un lugar público y concurrido donde puedas pedir ayuda.',
        'difficulty': 'básico',
        'points': 10,
      },
      {
        'id': 2,
        'question': 'Si alguien te ofrece un viaje gratis, ¿qué debes hacer?',
        'options': [
          'Aceptar agradecidamente',
          'Preguntar más detalles',
          'Rechazar educadamente y reportar',
          'Pedir tiempo para pensarlo',
        ],
        'correctAnswer': 2,
        'explanation':
            'Nunca aceptes ofertas de viaje de desconocidos. Rechaza educadamente y reporta la situación.',
        'difficulty': 'intermedio',
        'points': 15,
      },
      {
        'id': 3,
        'question': '¿Cuál es la mejor forma de compartir tu ubicación?',
        'options': [
          'Solo con amigos cercanos',
          'Con contactos de confianza predefinidos',
          'En redes sociales para que todos vean',
          'No compartir nunca mi ubicación',
        ],
        'correctAnswer': 1,
        'explanation':
            'Comparte tu ubicación solo con contactos de confianza predefinidos, no en redes sociales.',
        'difficulty': 'intermedio',
        'points': 15,
      },
    ];
  }

  // Obtener consejos por categoría
  List<Map<String, dynamic>> getTipsByCategory(String category) {
    return _preventionTips.where((tip) => tip['category'] == category).toList();
  }

  // Obtener consejos por dificultad
  List<Map<String, dynamic>> getTipsByDifficulty(String difficulty) {
    return _preventionTips
        .where((tip) => tip['difficulty'] == difficulty)
        .toList();
  }

  // Obtener escenario actual
  Map<String, dynamic>? getCurrentScenario() {
    if (_currentLessonIndex < _interactiveScenarios.length) {
      return _interactiveScenarios[_currentLessonIndex];
    }
    return null;
  }

  // Avanzar al siguiente escenario
  void nextScenario() {
    if (_currentLessonIndex < _interactiveScenarios.length - 1) {
      _currentLessonIndex++;
      notifyListeners();
    }
  }

  // Retroceder al escenario anterior
  void previousScenario() {
    if (_currentLessonIndex > 0) {
      _currentLessonIndex--;
      notifyListeners();
    }
  }

  // Responder escenario interactivo
  void answerScenario(int scenarioId, int selectedAnswer) {
    final scenario = _interactiveScenarios.firstWhere(
      (s) => s['id'] == scenarioId,
      orElse: () => {},
    );

    if (scenario.isNotEmpty) {
      bool isCorrect = selectedAnswer == scenario['correctAnswer'];
      int points = isCorrect ? scenario['points'] : 0;

      _totalScore += points.toInt();

      // Guardar progreso del usuario
      _userProgress.add({
        'scenarioId': scenarioId,
        'selectedAnswer': selectedAnswer,
        'isCorrect': isCorrect,
        'points': points,
        'timestamp': DateTime.now().toIso8601String(),
      });

      notifyListeners();
      _saveProgress();
    }
  }

  // Obtener progreso del usuario
  double getUserProgressPercentage() {
    if (_interactiveScenarios.isEmpty) return 0.0;
    int completedScenarios =
        _userProgress.map((p) => p['scenarioId']).toSet().length;
    return (completedScenarios / _interactiveScenarios.length) * 100;
  }

  // Obtener puntuación por dificultad
  Map<String, num> getScoreByDifficulty() {
    Map<String, num> scores = {};

    for (var progress in _userProgress) {
      final scenario = _interactiveScenarios.firstWhere(
        (s) => s['id'] == progress['scenarioId'],
        orElse: () => {},
      );

      if (scenario.isNotEmpty) {
        String difficulty = scenario['difficulty'];
        scores[difficulty] = (scores[difficulty] ?? 0) + progress['points'];
      }
    }

    return scores;
  }

  // Guardar progreso en almacenamiento local
  Future<void> _saveProgress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('total_score', _totalScore.toDouble());
      // Aquí se guardaría el progreso completo en JSON
    } catch (e) {
      debugPrint('Error guardando progreso: $e');
    }
  }

  // Cargar progreso desde almacenamiento local
  Future<void> loadProgress() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _totalScore = prefs.getDouble('total_score') ?? 0;
      // Aquí se cargaría el progreso completo desde JSON
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando progreso: $e');
    }
  }

  // Reiniciar progreso
  void resetProgress() {
    _currentLessonIndex = 0;
    _totalScore = 0;
    _userProgress.clear();
    notifyListeners();
    _saveProgress();
  }
}
