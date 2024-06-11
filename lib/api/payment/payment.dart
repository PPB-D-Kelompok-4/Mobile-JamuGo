import 'package:dio/dio.dart';
import 'package:jamugo/utils/secure_storage.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://103.127.132.182:3009/api',
));

class PaymentApi {
  static Future<String?> getToken() async {
    final token = await SecureStorageUtil.readSecureData(key: 'token');
    return token;
  }

  static Future<PaymentResponse> initiatePayment(int orderPkid) async {
    final token = await getToken();
    final response = await dio.post(
      '/payment/snap/initiate/',
      data: {
        'order_pkid': orderPkid,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return PaymentResponse.fromJson(response.data);
  }
}

class PaymentResponse {
  final String? token;
  final Uri? redirectUrl;
  final String message;
  final bool isSuccess;
  final int status;

  PaymentResponse({
    this.token,
    this.redirectUrl,
    required this.message,
    required this.isSuccess,
    required this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      token: json['data']['token'],
      redirectUrl: Uri.parse(json['data']['redirect_url']),
      message: json['message'],
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}
