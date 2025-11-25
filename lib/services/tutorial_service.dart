import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _keyFirstLaunch = 'tutorial_first_launch';
  static const String _keyHomeVisited = 'tutorial_home_visited';
  static const String _keyDisciplinasVisited = 'tutorial_disciplinas_visited';
  static const String _keyDailyGoalsVisited = 'tutorial_daily_goals_visited';
  static const String _keyPerfilVisited = 'tutorial_perfil_visited';

  // Verificar se é a primeira vez que abre o app
  static Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyFirstLaunch) != true;
    } catch (e) {
      return true;
    }
  }

  // Marcar que o app já foi aberto
  static Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, true);
  }

  // Verificar se uma aba específica já foi visitada
  static Future<bool> hasVisitedTab(String tabName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTabKey(tabName);
      return prefs.getBool(key) == true;
    } catch (e) {
      return false;
    }
  }

  // Marcar que uma aba foi visitada
  static Future<void> markTabVisited(String tabName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getTabKey(tabName);
    await prefs.setBool(key, true);
  }

  static String _getTabKey(String tabName) {
    switch (tabName) {
      case 'home':
        return _keyHomeVisited;
      case 'disciplinas':
        return _keyDisciplinasVisited;
      case 'daily_goals':
        return _keyDailyGoalsVisited;
      case 'perfil':
        return _keyPerfilVisited;
      default:
        return 'tutorial_${tabName}_visited';
    }
  }

  // Reiniciar tutorial (útil para testes)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstLaunch);
    await prefs.remove(_keyHomeVisited);
    await prefs.remove(_keyDisciplinasVisited);
    await prefs.remove(_keyDailyGoalsVisited);
    await prefs.remove(_keyPerfilVisited);
  }
}

