import 'package:flutter/material.dart';

import '../../services/preferences_service.dart';

/// InheritedWidget para disponibilizar o ThemeController na árvore de widgets.
class ThemeControllerProvider extends InheritedWidget {
  final ThemeController controller;

  const ThemeControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    assert(provider != null, 'ThemeControllerProvider not found in context');
    return provider!.controller;
  }

  static ThemeController? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    return provider?.controller;
  }

  @override
  bool updateShouldNotify(ThemeControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Controlador de tema do aplicativo.
///
/// Gerencia o [ThemeMode] atual e notifica ouvintes quando ele muda.
/// Isso permite que o [MaterialApp] reconstrua com o novo tema.
class ThemeController extends ChangeNotifier {
  /// Modo de tema atual. Começa seguindo o sistema.
  ThemeMode _mode = ThemeMode.system;

  /// Retorna o modo de tema atual.
  ThemeMode get mode => _mode;

  /// Retorna true se o modo atual é escuro.
  bool get isDarkMode => _mode == ThemeMode.dark;

  /// Retorna true se o modo atual segue o sistema.
  bool get isSystemMode => _mode == ThemeMode.system;

  /// Carrega o tema salvo do armazenamento.
  ///
  /// Deve ser chamado antes do runApp() no main.dart.
  Future<void> load() async {
    final savedMode = await PreferencesService.getThemeMode();
    _mode = _stringToThemeMode(savedMode);
    // Não chama notifyListeners() aqui pois ainda não há ouvintes
    debugPrint('🎨 Tema carregado: $savedMode → $_mode');
  }

  /// Altera o modo de tema, salva e notifica os ouvintes.
  ///
  /// Exemplo:
  /// ```dart
  /// controller.setMode(ThemeMode.dark);
  /// ```
  Future<void> setMode(ThemeMode newMode) async {
    if (_mode != newMode) {
      _mode = newMode;
      await PreferencesService.setThemeMode(_themeModeToString(newMode));
      notifyListeners();
    }
  }

  /// Alterna entre claro e escuro.
  ///
  /// Se estiver em modo sistema, detecta o tema atual e inverte.
  Future<void> toggle(Brightness currentBrightness) async {
    ThemeMode newMode;
    if (_mode == ThemeMode.system) {
      // Se estava em sistema, vai para o oposto do atual
      newMode = currentBrightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    } else {
      // Alterna entre claro e escuro
      newMode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    await setMode(newMode);
  }

  /// Converte String para ThemeMode.
  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Converte ThemeMode para String.
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
