import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_attendance/core/app_config.dart';
import 'package:smart_attendance/core/base_provider.dart';
import 'package:smart_attendance/model/profile_model.dart';

class ProfileService {
  final ApiProvider _api = ApiProvider();

  ProfileService();

  Future<void> _attachToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      _api.setBearerToken(token);
    }
  }

  /// Fetch user profile
  Future<Profile> getProfile() async {
    await _attachToken();
    final raw = await _api.get(Endpoints.profile);
    return Profile.fromJson(raw as Map<String, dynamic>);
  }

  Future<dynamic> updateProfilePicture(File imageFile) async {
    await _attachToken();

    // prepare data URI
    final bytes = await imageFile.readAsBytes();
    final ext = imageFile.path.split('.').last;
    final mime = 'image/$ext';
    final base64Str = base64Encode(bytes);
    final dataUri = 'data:$mime;base64,$base64Str';

    // panggil existing MultipartRequest helper
    return _api.postFormDataWithImage(
      Endpoints.updateProfile,
      fields: {'new_photo': dataUri},
      imageFile: imageFile,
      imageFieldName: 'dummy_field',
    );
  }
}
