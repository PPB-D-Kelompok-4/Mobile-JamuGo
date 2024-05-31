import 'package:dio/dio.dart';
import 'package:mobile_jamugo/utils/secure_storage.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://103.127.132.182:3009/api',
));

class MenuApi {
  static Future<String?> getToken() async {
    final token = await SecureStorage.readSecureData(key: 'token');
    return token;
  }

  static Future<List<Menu>> getAllMenus() async {
    final token = await getToken();
    final response = await dio.get(
      '/menu',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final List<dynamic> data = response.data['data'];
    return data.map((e) => Menu.fromJson(e)).toList();
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

    return Menu.fromJson(response.data);
  }

  static Future<void> createMenu({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
  }) async {
    final token = await getToken();
    await dio.post(
      '/menu',
      data: {
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  static Future<void> deleteMenu(int id) async {
    final token = await getToken();
    await dio.delete(
      '/menu/$id',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}

class Menu {
  final int pkid;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String createdBy;
  final String createdDate;
  final String createdHost;
  final String? updatedBy;
  final String? updatedDate;
  final String? updatedHost;
  final bool isDeleted;
  final String? deletedBy;
  final String? deletedDate;
  final String? deletedHost;

  Menu({
    required this.pkid,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.createdBy,
    required this.createdDate,
    required this.createdHost,
    required this.updatedBy,
    required this.updatedDate,
    required this.updatedHost,
    required this.isDeleted,
    required this.deletedBy,
    required this.deletedDate,
    required this.deletedHost,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    const String baseUrl = "http://103.127.132.182:3009";
    String imageUrl = json['image_url'];
    if (imageUrl.startsWith('undefined')) {
      imageUrl = imageUrl.replaceFirst('undefined', baseUrl);
    }
    return Menu(
      pkid: json['pkid'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      imageUrl: imageUrl,
      createdBy: json['created_by'],
      createdDate: json['created_date'],
      createdHost: json['created_host'],
      updatedBy: json['updated_by'],
      updatedDate: json['updated_date'],
      updatedHost: json['updated_host'],
      isDeleted: json['is_deleted'],
      deletedBy: json['deleted_by'],
      deletedDate: json['deleted_date'],
      deletedHost: json['deleted_host'],
    );
  }
}
