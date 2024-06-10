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

  static Future<CreateOrderResponse> createOrder() async {
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

    return CreateOrderResponse.fromJson(response.data);
  }

  static Future<OrderListResponse> getOrdersByUser() async {
    final token = await getToken();
    final response = await dio.get(
      '/order',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return OrderListResponse.fromJson(response.data);
  }

  static Future<OrderListResponse> getOrdersByAdmin(
      String status, bool sortByDate) async {
    final token = await getToken();
    final response = await dio.get(
      '/order/admin/all',
      queryParameters: {
        'status': status,
        'sortByDate': sortByDate,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return OrderListResponse.fromJson(response.data);
  }

  static Future<OrderDetailResponse> getOrderById(int id) async {
    final token = await getToken();
    final response = await dio.get(
      '/order/$id',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return OrderDetailResponse.fromJson(response.data);
  }

    static Future<CreateOrderResponse> cancelOrderByAdmin(int id) async {
    final token = await getToken();
    final response = await dio.put(
      '/order/admin/cancel',
      queryParameters: {
        'pkid': id,
      },
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return CreateOrderResponse.fromJson(response.data);
  }

  static Future<CreateOrderResponse> cancelOrder(int id) async {
    final token = await getToken();
    final response = await dio.put(
      '/order/cancel/$id',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return CreateOrderResponse.fromJson(response.data);
  }

  static Future<CreateOrderResponse> updateOrderStatus(int id, String status) async {
    final token = await getToken();
    final response = await dio.put(
      '/order/status/$id',
      data: {'status': status},
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return CreateOrderResponse.fromJson(response.data);
  }
}

class CreateOrderResponse {
  final Map<String, dynamic>? data;
  final String message;
  final bool isSuccess;
  final int status;
  final int orderId;

  CreateOrderResponse({
    required this.data,
    required this.message,
    required this.isSuccess,
    required this.status,
    required this.orderId,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      data: json['data'],
      orderId: json['data'] != null ? json['data']['pkid'] : 0,
      message: json['message'],
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}

class OrderListResponse {
  final List<Order> orders;
  final String message;
  final bool isSuccess;
  final int status;

  OrderListResponse({
    required this.orders,
    required this.message,
    required this.isSuccess,
    required this.status,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      orders: (json['data'] as List).map((i) => Order.fromJson(i)).toList(),
      message: json['message'],
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}

class OrderDetailResponse {
  final Order? data;
  final String message;
  final bool isSuccess;
  final int status;

  OrderDetailResponse({
    required this.data,
    required this.message,
    required this.isSuccess,
    required this.status,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailResponse(
      data: json['data'] != null ? Order.fromJson(json['data']) : null,
      message: json['message'],
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}

class Order {
  final int pkid;
  final int userPkid;
  final String status;
  final double totalPrice;
  final String createdBy;
  final String createdDate;
  final List<OrderItem> items;
  final OrderStatus? orderStatus;

  Order({
    required this.pkid,
    required this.userPkid,
    required this.status,
    required this.totalPrice,
    required this.createdBy,
    required this.createdDate,
    required this.items,
    this.orderStatus,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      pkid: json['pkid'],
      userPkid: json['user_pkid'],
      status: json['status'],
      totalPrice: double.parse(json['total_price'].toString()),
      createdBy: json['created_by'],
      createdDate: json['created_date'],
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
      orderStatus: json['orderStatus'] != null
          ? OrderStatus.fromJson(json['orderStatus'])
          : null,
    );
  }
}

class OrderStatus {
  final int pkid;
  final int orderPkid;
  final String status;

  OrderStatus({
    required this.pkid,
    required this.orderPkid,
    required this.status,
  });

  factory OrderStatus.fromJson(Map<String, dynamic> json) {
    return OrderStatus(
      pkid: json['pkid'],
      orderPkid: json['order_pkid'],
      status: json['status'],
    );
  }
}

class OrderItem {
  final int pkid;
  final int orderPkid;
  final int menuPkid;
  final int quantity;
  final double price;

  OrderItem({
    required this.pkid,
    required this.orderPkid,
    required this.menuPkid,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      pkid: json['pkid'],
      orderPkid: json['order_pkid'],
      menuPkid: json['menu_pkid'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
    );
  }
}
