import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Chaves para dados do perfil
  static const String _userNameKey = 'nome_usuario';
  static const String _userEmailKey = 'email_usuario';
  static const String _userPhotoPathKey = 'userPhotoPath';
  static const String _userPhotoUpdatedAtKey = 'userPhotoUpdatedAt';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  // Métodos para nome do usuário
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Usuário';
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // Métodos para email do usuário
  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey) ?? 'usuario@exemplo.com';
  }

  static Future<void> setUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  // Métodos para foto do usuário
  static Future<String?> getUserPhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhotoPathKey);
  }

  static Future<void> setUserPhotoPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString(_userPhotoPathKey, path);
    } else {
      await prefs.remove(_userPhotoPathKey);
    }
  }

  // Métodos para timestamp da foto
  static Future<int?> getUserPhotoUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userPhotoUpdatedAtKey);
  }

  static Future<void> setUserPhotoUpdatedAt(int? timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    if (timestamp != null) {
      await prefs.setInt(_userPhotoUpdatedAtKey, timestamp);
    } else {
      await prefs.remove(_userPhotoUpdatedAtKey);
    }
  }

  // Métodos para notificações
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  // Método para limpar dados do perfil (incluindo foto)
  static Future<void> clearProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhotoPathKey);
    await prefs.remove(_userPhotoUpdatedAtKey);
    await prefs.remove(_notificationsEnabledKey);
  }

  // Método para limpar todos os dados do app
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

