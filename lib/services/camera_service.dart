import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();
  static CameraDevice _currentCamera = CameraDevice.front;

  static CameraDevice get currentCamera => _currentCamera;

  static void switchCamera() {
    _currentCamera = _currentCamera == CameraDevice.front 
        ? CameraDevice.rear 
        : CameraDevice.front;
  }

  static Future<String?> takeSelfie({CameraDevice? cameraDevice}) async {
    try {
      final CameraDevice deviceToUse = cameraDevice ?? _currentCamera;
      
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: deviceToUse,
        imageQuality: 80,
      );

      if (photo != null) {
        // Save photo to app directory
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = '${appDir.path}/$fileName';
        
        await File(photo.path).copy(filePath);
        return filePath;
      }
    } catch (e) {
      // Handle error silently or log to analytics
      return null;
    }
    return null;
  }

  static Future<bool> checkCameraPermission() async {
    // Permission checking is handled by image_picker plugin automatically
    return true;
  }

  static String getCameraLabel() {
    return _currentCamera == CameraDevice.front ? 'Front Camera' : 'Rear Camera';
  }
}
