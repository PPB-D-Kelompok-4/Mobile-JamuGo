import 'package:dio/dio.dart';
import 'package:jamugo/utils/secure_storage.dart';

final dio = Dio(BaseOptions(
  baseUrl: 'http://103.127.132.182:3009/api',
));

class TransactionApi {
  static Future<String?> getToken() async {
    final token = await SecureStorageUtil.readSecureData(key: 'token');
    return token;
  }

  static Future<TransactionResponse> getTransactionByOrderId(
      int orderId) async {
    final token = await getToken();
    final response = await dio.get(
      '/transaction/order/$orderId',
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return TransactionResponse.fromJson(response.data);
  }

  static Future<UpdateTransactionResponse> updatePaymentMethod(
      int orderId, String paymentMethod) async {
    final token = await getToken();
    final response = await dio.put(
      '/transaction/payment-method/$orderId',
      data: {'payment_method': paymentMethod},
      options: Options(
        validateStatus: (status) => true,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return UpdateTransactionResponse.fromJson(response.data);
  }
}

class TransactionResponse {
  final List<Transaction> transactions;
  final String message;
  final bool isSuccess;
  final int status;

  TransactionResponse({
    required this.transactions,
    required this.message,
    required this.isSuccess,
    required this.status,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactions:
          (json['data'] as List).map((i) => Transaction.fromJson(i)).toList(),
      message: json['message'],
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}

class UpdateTransactionResponse {
  final Transaction data;
  final String message;
  final String returnId;
  final bool isSuccess;
  final int status;

  UpdateTransactionResponse({
    required this.data,
    required this.message,
    required this.returnId,
    required this.isSuccess,
    required this.status,
  });

  factory UpdateTransactionResponse.fromJson(Map<String, dynamic> json) {
    return UpdateTransactionResponse(
      data: Transaction.fromJson(json['data']),
      message: json['message'],
      returnId: json['returnId'],
      isSuccess: json['isSuccess'],
      status: json['status'],
    );
  }
}

class Transaction {
  final int pkid;
  final int orderPkid;
  final String paymentStatus;
  final String paymentMethod;
  final String transactionDate;

  Transaction({
    required this.pkid,
    required this.orderPkid,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      pkid: json['pkid'],
      orderPkid: json['order_pkid'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      transactionDate: json['transaction_date'],
    );
  }
}
