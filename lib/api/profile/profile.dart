import 'package:dio/dio.dart';
import 'dart:io';
import 'package:jamugo/utils/secure_storage.dart';
import 'package:path_provider/path_provider.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://103.127.132.182:3009/api',
));

class ProfileApi {
  static Future<String?> getToken() async {
    final token = await SecureStorageUtil.readSecureData(key: 'token');
    return token;
  }

  static Future<ProfileResponse> getUserData() async {
    final token = await getToken();
    final response = await dio.get(
      '/user/me',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return ProfileResponse.fromJson(response.data['data']);
  }

  static Future<File> getUserImage(String filename) async {
    final token = await getToken();
    final response = await dio.get(
      'http://103.127.132.182:3009/api/user/profile-image/$filename',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        responseType: ResponseType.bytes,
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(response.data);

    return file;
  }

  static Future<void> uploadProfileImage(File image) async {
    final token = await getToken();
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path),
    });

    await dio.post(
      '/user/upload-profile-image/',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<void> updateUserData(int pkid, String name, String address) async {
    final token = await getToken();
    await dio.put(
      '/user/$pkid',
      data: {
        'name': name,
        'address': address,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}

class ProfileResponse {
  final String name;
  final String address;
  final String email;
  final int pkid;
  final String role;
  final String? imageProfile;

  ProfileResponse({
    required this.name,
    required this.address,
    required this.email,
    required this.pkid,
    required this.role,
    this.imageProfile,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      name: json['name'],
      address: json['address'],
      email: json['email'],
      pkid: json['pkid'],
      role: json['role_pkid'] == 2 ? 'Admin' : 'Customer',
      imageProfile: json['image_profile'],
    );
  }
}
