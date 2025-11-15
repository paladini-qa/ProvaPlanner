import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class LocalPhotoStore {
  static const String _avatarFileName = 'avatar.jpg';
  static const int _quality = 80;
  static const int _maxFileSizeBytes = 200 * 1024; // 200KB

  /// Salva uma foto comprimindo-a e removendo metadados EXIF
  static Future<String> savePhoto(File imageFile) async {
    try {
      // Verificar se o arquivo existe
      // ignore: avoid_slow_async_io
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      // Verificar tamanho do arquivo original (máximo 10MB)
      // ignore: avoid_slow_async_io
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Imagem muito grande. Máximo permitido: 10MB');
      }

      // Obter diretório de documentos do app
      final appDir = await getApplicationDocumentsDirectory();
      final avatarPath = '${appDir.path}/$_avatarFileName';

      // Comprimir a imagem
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        avatarPath,
        quality: _quality,
        minWidth: 100,
        minHeight: 100,
        keepExif: false, // Remove metadados EXIF/GPS
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Falha ao comprimir a imagem');
      }

      // Verificar tamanho do arquivo comprimido
      // ignore: avoid_slow_async_io
      final compressedSize = await compressedFile.length();
      if (compressedSize > _maxFileSizeBytes) {
        // Tentar compressão mais agressiva
        final moreCompressedFile = await FlutterImageCompress.compressAndGetFile(
          imageFile.absolute.path,
          avatarPath,
          quality: 60,
          minWidth: 100,
          minHeight: 100,
          keepExif: false,
          format: CompressFormat.jpeg,
        );

        if (moreCompressedFile == null) {
          throw Exception('Falha ao comprimir a imagem para o tamanho desejado');
        }

        // ignore: avoid_slow_async_io
        final finalSize = await moreCompressedFile.length();
        if (finalSize > _maxFileSizeBytes) {
          throw Exception('Imagem muito grande mesmo após compressão');
        }

        return moreCompressedFile.path;
      }

      return compressedFile.path;
    } catch (e) {
      throw Exception('Erro ao salvar foto: ${e.toString()}');
    }
  }

  /// Retorna o caminho da foto do avatar se existir
  static Future<String?> getPhotoPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarPath = '${appDir.path}/$_avatarFileName';
      final file = File(avatarPath);

      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        return avatarPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Remove a foto do avatar
  static Future<void> deletePhoto() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarPath = '${appDir.path}/$_avatarFileName';
      final file = File(avatarPath);

      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        // ignore: avoid_slow_async_io
        await file.delete();
      }
    } catch (e) {
      throw Exception('Erro ao remover foto: ${e.toString()}');
    }
  }

  /// Verifica se a foto existe e é válida
  static Future<bool> photoExists() async {
    try {
      final path = await getPhotoPath();
      if (path == null) return false;

      final file = File(path);
      // ignore: avoid_slow_async_io
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Retorna informações sobre a foto (tamanho, dimensões)
  static Future<Map<String, dynamic>?> getPhotoInfo() async {
    try {
      final path = await getPhotoPath();
      if (path == null) return null;

      final file = File(path);
      // ignore: avoid_slow_async_io
      if (!await file.exists()) return null;

      // ignore: avoid_slow_async_io
      final fileSize = await file.length();
      return {
        'path': path,
        'sizeBytes': fileSize,
        'sizeKB': (fileSize / 1024).round(),
        'exists': true,
      };
    } catch (e) {
      return null;
    }
  }
}
