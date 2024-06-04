import 'package:dio/dio.dart';
import 'package:jamugo/utils/secure_storage.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://103.127.132.182:3009/api',
));

class AuthApi {
  static Future<String?> getToken() async {
    final token = await SecureStorageUtil.readSecureData(key: 'token');
    return token;
  }

  static Future<RegisterResponse> register({
    required String email,
    required String password,
    required String name,
    required String address,
  }) async {
    final response = await dio.post('/user/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'address': address,
        },
        options: Options(
          validateStatus: (status) => true,
        ));

    return RegisterResponse.fromJson(response.data);
  }

  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post('/user/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => true,
        ));

    return LoginResponse.fromJson(response.data);
  }

  static Future<CheckTokenResponse> checkToken() async {
    final token = await getToken();
    final response = await dio.get(
      '/user/check-token',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return CheckTokenResponse.fromJson(response.data);
  }
}

class RegisterResponse {
  final String message;
  final bool isSuccess;
  final int status;

  RegisterResponse({
    required this.message,
    required this.isSuccess,
    required this.status,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final temp = json['message'].split("-")[1];
    return RegisterResponse(
      message: temp,
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}

class LoginResponse {
  final String message;
  final bool isSuccess;
  final int status;
  final String? token;

  LoginResponse({
    required this.message,
    required this.isSuccess,
    required this.status,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final temp = json['message'].split("-")[1];
    return LoginResponse(
      message: temp,
      isSuccess: json['isSuccess'],
      status: json['status'],
      token: json['isSuccess'] == true ? json['data']['token'] : null,
    );
  }
}

class CheckTokenResponse {
  final String message;
  final bool isSuccess;
  final int status;
  final String role;
  final String name;

  CheckTokenResponse({
    required this.message,
    required this.isSuccess,
    required this.status,
    required this.role,
    required this.name,
  });

  factory CheckTokenResponse.fromJson(Map<String, dynamic> json) {
    final temp = json['message'].split("-")[1];
    return CheckTokenResponse(
      message: temp,
      isSuccess: json['isSuccess'],
      status: json['status'],
      role: json['data']['role'],
      name: json['data']['name'],
    );
  }
}
