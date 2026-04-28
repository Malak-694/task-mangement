import 'dart:io';

import 'package:mobile_assignment/feature/auth/services/local_auth_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalProfileService {
  LocalProfileService._();
  static final LocalProfileService instance = LocalProfileService._();

  Future<String?> saveAvatarImage(File imageFile, String email) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory(p.join(appDir.path, 'avatars'));

      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      final sanitizedEmail = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final destPath = p.join(avatarDir.path, '$sanitizedEmail.jpg');

      await imageFile.copy(destPath);
      return destPath;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUser({
    required String email,
    required String name,
    required String studentId,
    required String password,
    File? avatarFile,
  }) async {
    final db = LocalAuthService.instance.database;
    if (db == null) return false;
    final data = <String, dynamic>{
      'name': name,
      'student_id': studentId,
      'password': password,
    };

    if (avatarFile != null) {
      final oldUser = await getUserByEmail(email);
      final oldAvatarPath = oldUser?['avatar_path'] as String?;
      if (oldAvatarPath != null) {
        final oldFile = File(oldAvatarPath);
        if (await oldFile.exists()) await oldFile.delete();
      }

      final newAvatarPath = await saveAvatarImage(avatarFile, email);
      if (newAvatarPath != null) {
        data['avatar_path'] = newAvatarPath;
      }
    }
    final rows = await db.update(
      'users',
      data,
      where: 'email = ?',
      whereArgs: [email],
    );

    return rows > 0;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return LocalAuthService.instance.getUserByEmail(email);
  }
}