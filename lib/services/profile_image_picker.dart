import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageService {
  static const _key = "profile_image";

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return null;

    final directory = await getApplicationDocumentsDirectory();

    final saved = await File(image.path).copy(
      "${directory.path}/profile_picture.jpg",
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, saved.path);

    return saved;
  }

  static Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> removeImage() async {
    final prefs = await SharedPreferences.getInstance();

    final path = prefs.getString(_key);

    if (path != null) {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove(_key);
  }
}