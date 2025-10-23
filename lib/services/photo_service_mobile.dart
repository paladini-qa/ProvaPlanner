import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'photo_service.dart';

class MobilePhotoService implements PhotoService {
  static const String _avatarFileName = 'avatar.jpg';
  static const int _quality = 80;
  static const int _maxFileSizeBytes = 200 * 1024; // 200KB

  @override
  Future<String> savePhoto(dynamic imageFile) async {
    if (imageFile is! File) {
      throw Exception('Tipo de arquivo não suportado');
    }
    
    try {
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Imagem muito grande. Máximo permitido: 10MB');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final avatarPath = '${appDir.path}/$_avatarFileName';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        avatarPath,
        quality: _quality,
        minWidth: 100,
        minHeight: 100,
        keepExif: false,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Falha ao comprimir a imagem');
      }

      final compressedSize = await compressedFile.length();
      if (compressedSize > _maxFileSizeBytes) {
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

        return moreCompressedFile.path;
      }

      return compressedFile.path;
    } catch (e) {
      throw Exception('Erro ao salvar foto: ${e.toString()}');
    }
  }

  @override
  Future<String?> getPhotoPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarPath = '${appDir.path}/$_avatarFileName';
      final file = File(avatarPath);

      if (await file.exists()) {
        return avatarPath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deletePhoto() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarPath = '${appDir.path}/$_avatarFileName';
      final file = File(avatarPath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Erro ao remover foto: ${e.toString()}');
    }
  }

  @override
  Future<bool> photoExists() async {
    try {
      final path = await getPhotoPath();
      if (path == null) return false;

      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> getPhotoInfo() async {
    try {
      final path = await getPhotoPath();
      if (path == null) return null;

      final file = File(path);
      if (!await file.exists()) return null;

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

PhotoService getPhotoService() => MobilePhotoService();

