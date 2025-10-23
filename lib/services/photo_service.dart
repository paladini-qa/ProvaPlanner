// Conditional imports
import 'photo_service_stub.dart'
    if (dart.library.io) 'photo_service_mobile.dart'
    if (dart.library.html) 'photo_service_web.dart';

abstract class PhotoService {
  static PhotoService get instance => getPhotoService();
  
  Future<String> savePhoto(dynamic imageFile);
  Future<String?> getPhotoPath();
  Future<void> deletePhoto();
  Future<bool> photoExists();
  Future<Map<String, dynamic>?> getPhotoInfo();
}
