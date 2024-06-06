import 'package:dio/dio.dart';
import 'package:jamugo/utils/secure_storage.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://103.127.132.182:3009/api',
));

class OrderApi {
  static Future<String?> getToken() async {
    final token = await SecureStorageUtil.readSecureData(key: 'token');
    return token;
  }

  static Future<OrderResponse> createOrder() async {
    final token = await getToken();
    final response = await dio.post(
      '/order',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return OrderResponse.fromJson(response.data);
  }
}

class OrderResponse {
  final Map<String, dynamic>? data;
  final String message;
  final bool isSuccess;
  final int status;

  OrderResponse({
    required this.data,
    required this.message,
    required this.isSuccess,
    required this.status,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      data: json['data'],
      message: json['message'],
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}
