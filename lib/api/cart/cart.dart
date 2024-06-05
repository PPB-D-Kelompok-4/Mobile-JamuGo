import 'package:dio/dio.dart';
import 'package:jamugo/api/menu/menu.dart';
import 'package:jamugo/utils/secure_storage.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://103.127.132.182:3009/api',
));

class CartApi {
  static Future<String?> getToken() async {
    final token = await SecureStorageUtil.readSecureData(key: 'token');
    return token;
  }

  static Future<CartResponse> createOrUpdateCartItem({
    required int menuPkid,
    required int quantity,
  }) async {
    final token = await getToken();
    final response = await dio.post(
      '/cart/item',
      data: {
        'menu_pkid': menuPkid,
        'quantity': quantity,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return CartResponse.fromJson(response.data);
  }

  static Future<CartResponse> getCartByUser() async {
    final token = await getToken();
    final response = await dio.get(
      '/cart/user',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return CartResponse.fromJson(response.data);
  }

  static Future<void> deleteCartItem(int itemId) async {
    final token = await getToken();
    await dio.delete(
      '/cart/item/$itemId',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

    static Future<Menu> getMenuById(int id) async {
    final token = await getToken();
    final response = await dio.get(
      '/menu/$id',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return Menu.fromJson(response.data['data']);
  }
}

class CartResponse {
  final Map<String, dynamic>? data;
  final String message;
  final bool isSuccess;
  final int status;

  CartResponse({
    required this.data,
    required this.message,
    required this.isSuccess,
    required this.status,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      data: json['data'],
      message: json['message'],
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}
