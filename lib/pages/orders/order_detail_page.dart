import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamugo/api/order/order.dart';
import 'package:jamugo/api/menu/menu.dart';
import 'package:intl/intl.dart';
import 'package:jamugo/utils/shared_preferences.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<OrderDetailResponse> orderDetailFuture;
  late String role;
  Map<int, Future<Menu>> menuDetails = {};

  @override
  void initState() {
    super.initState();
    orderDetailFuture = OrderApi.getOrderById(widget.orderId);
    _getRole();
  }

  Future<void> _getRole() async {
    final getRole = await SharedPreferencesUtil.readData(key: 'role');
    setState(() {
      role = getRole ?? '';
    });
  }

  String _formatPrice(double price) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }

  String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    final format = DateFormat('yyyy-MM-dd HH:mm');
    return format.format(dateTime);
  }

  void _showToast(String message, {Color backgroundColor = Colors.red}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
    );
  }

  Future<Menu> _fetchMenuDetails(int menuPkid) async {
    if (!menuDetails.containsKey(menuPkid)) {
      menuDetails[menuPkid] = MenuApi.getMenuById(menuPkid);
    }
    return await menuDetails[menuPkid]!;
  }

  Future<void> _cancelOrder(int orderId) async {
    try {
      final response = await OrderApi.cancelOrder(orderId);
      if (response.isSuccess) {
        _showToast('Order cancelled successfully',
            backgroundColor: Colors.green);
        setState(() {
          orderDetailFuture = OrderApi.getOrderById(orderId);
        });
      } else {
        _showToast('Failed to cancel order: ${response.message}');
      }
    } catch (error) {
      _showToast('Failed to cancel order: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Detail',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<OrderDetailResponse>(
        future: orderDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          } else if (snapshot.hasError) {
            _showToast('Error: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.data == null) {
            _showToast('Order details not found',
                backgroundColor: Colors.orange);
            return const Center(
              child: Text('Order details not found'),
            );
          } else {
            final order = snapshot.data!.data!;
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.pkid}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Created Date: ${_formatDate(order.createdDate)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Total Price: ${_formatPrice(order.totalPrice)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Status: ${order.status}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Items',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: ListView.builder(
                          itemCount: order.items.length,
                          itemBuilder: (context, index) {
                            final item = order.items[index];
                            return FutureBuilder<Menu>(
                              future: _fetchMenuDetails(item.menuPkid),
                              builder: (context, menuSnapshot) {
                                if (menuSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.green,
                                    ),
                                  );
                                } else if (menuSnapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${menuSnapshot.error}'),
                                  );
                                } else if (!menuSnapshot.hasData) {
                                  return const Center(
                                    child: Text('No menu data available'),
                                  );
                                } else {
                                  final menu = menuSnapshot.data!;
                                  return ListTile(
                                    leading: menu.imageUrl.isNotEmpty
                                        ? Image.network(
                                            menu.imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    title: Text(menu.name),
                                    subtitle: Text(
                                        'Quantity: ${item.quantity}, Price: ${_formatPrice(item.price)}'),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if ((role == 'user' && order.status == 'pending') ||
                    (role == 'admin' &&
                        order.status != 'completed' &&
                        order.status != 'cancelled'))
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: ElevatedButton(
                      onPressed: () {
                        _cancelOrder(order.pkid);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                      child: const Text(
                        'Cancel Order',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
