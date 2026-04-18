import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'imagekit_config.dart';

class ImageKitService {
  ImageKitService._();
  static final ImageKitService instance = ImageKitService._();

  Future<String?> uploadImage({
    required File imageFile,
    required String fileName,
    String folder = 'avatars',
  }) async {
    try {

      final expire = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final token  = _generateToken();
      final signature = _generateSignature(token, expire);


      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ImageKitConfig.uploadUrl),
      );

      request.fields['publicKey']  = ImageKitConfig.publicKey;
      request.fields['fileName']   = fileName;
      request.fields['folder']     = folder;
      request.fields['signature']  = signature;
      request.fields['expire']     = expire.toString();
      request.fields['token']      = token;

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response     = await request.send();
      final responseBody = await response.stream.bytesToString();
      final json         = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        debugPrint('ImageKit upload success: ${json['url']}');
        return json['url'] as String?;
      } else {
        debugPrint('ImageKit error: ${json['message']}');
        return null;
      }
    } catch (e, st) {
      debugPrint('ImageKitService.uploadImage failed: $e\n$st');
      return null;
    }
  }

  String _generateToken() {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    return base64Url.encode(utf8.encode(now)).replaceAll('=', '');
  }


  String _generateSignature(String token, int expire) {
    final key     = utf8.encode(ImageKitConfig.privateKey);
    final message = utf8.encode('$token$expire');
    final hmac    = Hmac(sha1, key);
    final digest  = hmac.convert(message);
    return digest.toString();
  }
}