import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../services/preferences_service.dart';
import '../../services/photo_service.dart';

class ProfileService {
  /// Obtém a foto do usuário
  static Future<dynamic> getPhoto() async {
    try {
      final photoPath = await PreferencesService.getUserPhotoPath();
      if (photoPath == null) return null;

      if (kIsWeb) {
        // Para web, retornar os dados da imagem
        final photoService = PhotoService.instance;
        final photoInfo = await photoService.getPhotoInfo();
        return photoInfo?['base64Data'];
      } else {
        // Para mobile, retornar o arquivo
        final file = File(photoPath);
        // ignore: avoid_slow_async_io
        if (await file.exists()) {
          return file;
        } else {
          // Arquivo não existe mais, limpar referência
          await PreferencesService.setUserPhotoPath(null);
          await PreferencesService.setUserPhotoUpdatedAt(null);
          return null;
        }
      }
    } catch (e) {
      return null;
    }
  }

  /// Define uma nova foto para o usuário
  static Future<void> setPhoto(dynamic imageFile) async {
    try {
      final photoService = PhotoService.instance;
      
      // Salvar e comprimir a foto
      final savedPath = await photoService.savePhoto(imageFile);
      
      // Atualizar preferências
      await PreferencesService.setUserPhotoPath(savedPath);
      await PreferencesService.setUserPhotoUpdatedAt(DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw Exception('Erro ao definir foto: ${e.toString()}');
    }
  }

  /// Remove a foto do usuário
  static Future<void> removePhoto() async {
    try {
      final photoService = PhotoService.instance;
      
      // Remover arquivo físico
      await photoService.deletePhoto();
      
      // Limpar preferências
      await PreferencesService.setUserPhotoPath(null);
      await PreferencesService.setUserPhotoUpdatedAt(null);
    } catch (e) {
      throw Exception('Erro ao remover foto: ${e.toString()}');
    }
  }

  /// Obtém o nome do usuário
  static Future<String> getName() async {
    return await PreferencesService.getUserName();
  }

  /// Define o nome do usuário
  static Future<void> setName(String name) async {
    await PreferencesService.setUserName(name);
  }

  /// Obtém o email do usuário
  static Future<String> getEmail() async {
    return await PreferencesService.getUserEmail();
  }

  /// Define o email do usuário
  static Future<void> setEmail(String email) async {
    await PreferencesService.setUserEmail(email);
  }

  /// Obtém o status das notificações
  static Future<bool> getNotificationsEnabled() async {
    return await PreferencesService.getNotificationsEnabled();
  }

  /// Define o status das notificações
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await PreferencesService.setNotificationsEnabled(enabled);
  }

  /// Obtém informações completas do perfil
  static Future<Map<String, dynamic>> getProfileData() async {
    final photo = await getPhoto();
    final photoService = PhotoService.instance;
    final photoInfo = await photoService.getPhotoInfo();
    
    return {
      'name': await getName(),
      'email': await getEmail(),
      'notificationsEnabled': await getNotificationsEnabled(),
      'hasPhoto': photo != null,
      'photoPath': photo is File ? photo.path : 'web_avatar_data',
      'photoInfo': photoInfo,
      'photoUpdatedAt': await PreferencesService.getUserPhotoUpdatedAt(),
    };
  }

  /// Atualiza múltiplos dados do perfil
  static Future<void> updateProfileData({
    String? name,
    String? email,
    bool? notificationsEnabled,
  }) async {
    if (name != null) {
      await setName(name);
    }
    if (email != null) {
      await setEmail(email);
    }
    if (notificationsEnabled != null) {
      await setNotificationsEnabled(notificationsEnabled);
    }
  }

  /// Limpa todos os dados do perfil (incluindo foto)
  static Future<void> clearProfileData() async {
    try {
      final photoService = PhotoService.instance;
      
      // Remover foto física
      await photoService.deletePhoto();
      
      // Limpar preferências
      await PreferencesService.clearProfileData();
    } catch (e) {
      throw Exception('Erro ao limpar dados do perfil: ${e.toString()}');
    }
  }

  /// Verifica se o usuário tem foto
  static Future<bool> hasPhoto() async {
    try {
      final photoService = PhotoService.instance;
      return await photoService.photoExists();
    } catch (e) {
      return false;
    }
  }

  /// Valida e corrige inconsistências na foto
  static Future<void> validateAndFixPhoto() async {
    try {
      final photoService = PhotoService.instance;
      final photoExists = await photoService.photoExists();
      
      if (!photoExists) {
        // Foto não existe mais, limpar referências
        await PreferencesService.setUserPhotoPath(null);
        await PreferencesService.setUserPhotoUpdatedAt(null);
      }
    } catch (e) {
      // Em caso de erro, limpar referências para evitar problemas
      await PreferencesService.setUserPhotoPath(null);
      await PreferencesService.setUserPhotoUpdatedAt(null);
    }
  }
}

