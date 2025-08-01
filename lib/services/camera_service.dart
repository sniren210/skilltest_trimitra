import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> takeSelfie() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
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
}
