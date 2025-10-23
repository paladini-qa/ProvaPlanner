import 'dart:typed_data';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'photo_service.dart';

class WebPhotoService implements PhotoService {
  static const String _avatarKey = 'user_avatar_data';
  static const int _maxFileSizeBytes = 200 * 1024; // 200KB

  @override
  Future<String> savePhoto(dynamic imageFile) async {
    try {
      Uint8List imageBytes;
      
      if (imageFile is Uint8List) {
        imageBytes = imageFile;
      } else {
        throw Exception('Tipo de arquivo não suportado na web');
      }

      // Verificar tamanho do arquivo
      if (imageBytes.length > 10 * 1024 * 1024) {
        throw Exception('Imagem muito grande. Máximo permitido: 10MB');
      }

      // Comprimir a imagem se necessário
      if (imageBytes.length > _maxFileSizeBytes) {
        // Para web, vamos usar uma compressão simples baseada em base64
        // Em uma implementação real, você poderia usar uma biblioteca de compressão
        imageBytes = await _compressImage(imageBytes);
      }

      // Converter para base64 para armazenar no SharedPreferences
      final base64String = base64Encode(imageBytes);
      
      // Salvar no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarKey, base64String);
      
      // Retornar um identificador único para a web
      return 'web_avatar_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Erro ao salvar foto: ${e.toString()}');
    }
  }

  @override
  Future<String?> getPhotoPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString(_avatarKey);
      
      if (base64String != null && base64String.isNotEmpty) {
        return 'web_avatar_data';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deletePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_avatarKey);
    } catch (e) {
      throw Exception('Erro ao remover foto: ${e.toString()}');
    }
  }

  @override
  Future<bool> photoExists() async {
    try {
      final path = await getPhotoPath();
      return path != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getPhotoInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString(_avatarKey);
      
      if (base64String == null || base64String.isEmpty) {
        return null;
      }

      final imageBytes = base64Decode(base64String);
      return {
        'path': 'web_avatar_data',
        'sizeBytes': imageBytes.length,
        'sizeKB': (imageBytes.length / 1024).round(),
        'exists': true,
        'base64Data': base64String,
      };
    } catch (e) {
      return null;
    }
  }

  /// Obtém os dados da imagem como Uint8List
  Future<Uint8List?> getImageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString(_avatarKey);
      
      if (base64String == null || base64String.isEmpty) {
        return null;
      }

      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }

  /// Compressão simples para web (em uma implementação real, use uma biblioteca adequada)
  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    // Esta é uma implementação simplificada
    // Em produção, você deveria usar uma biblioteca de compressão de imagem adequada
    // Por enquanto, vamos apenas retornar os bytes originais
    return imageBytes;
  }
}

PhotoService getPhotoService() => WebPhotoService();

