import 'package:dio/dio.dart';
import 'dart:io';
import 'package:jamugo/utils/secure_storage.dart';

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
      '/api/user/me',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    return ProfileResponse.fromJson(response.data);
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
    return response as File;
  }
}

class ProfileResponse {
  final String name;
  final String address;
  final String email;
  final String pkid;
  final String? imageProfile;

  ProfileResponse({
   required this.name,
   required this.address,
    required this.email,
    required this.pkid,
    required this.imageProfile,
});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      address: json['address'],
      email:json['email'],
      imageProfile: json['image_profile'],
      name: json['name'],
      pkid: json['pkid'],
    );
  }
}