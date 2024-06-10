import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamugo/api/order/order.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:jamugo/utils/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String role = '';
  late Future<OrderListResponse> orderFuture;

  @override
  void initState() {
    super.initState();
    _getOrders();
  }

  Future<void> _getOrders() async {
    final getRole = await SharedPreferencesUtil.readData(key: 'role');
    setState(() {
      role = getRole ?? '';
    });

    orderFuture = role == 'admin'
        ? OrderApi.getOrdersByAdmin('', true)
        : OrderApi.getOrdersByUser();
  }

  String _formatPrice(double price) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }

  String _formatDate(String date) {
    final dateTime = DateTime.parse(date);
    final addoffset = dateTime.add(const Duration(hours: 7));
    final format = DateFormat('dd MMMM yyyy HH:mm');

    return format.format(addoffset);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            orderFuture = role == 'admin'
                ? OrderApi.getOrdersByAdmin('', true)
                : OrderApi.getOrdersByUser();
          });
        },
        child: FutureBuilder<OrderListResponse>(
          future: orderFuture,
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
            } else if (!snapshot.hasData || snapshot.data!.orders.isEmpty) {
              _showToast('No orders available', backgroundColor: Colors.orange);
              return const Center(
                child: Text('No orders available'),
              );
            } else {
              final orders = snapshot.data!.orders;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push(
                        '/order_detail',
                        extra: order.pkid,
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Padding(
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
                            if (role == 'admin')
                              Text(
                                'Created By: ${order.createdBy}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            const SizedBox(height: 5),
                            Text(
                              'Date: ${_formatDate(order.createdDate)}',
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
                              'Status: ${order.status == 'process' ? 'Process' : order.status == 'completed' ? 'Completed' : order.status == 'pending' ? 'Pending' : order.status == 'preparing' ? 'Preparing' : order.status == 'order_placed' ? 'Order Placed' : order.status == 'ready_for_pickup' ? 'Ready For Pickup' : order.status == 'cancelled' ? 'Cancelled' : order.status == 'picked_up' ? 'Picked Up' : order.status}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            GoRouter.of(context).go('/home');
          } else if (index == 2) {
            GoRouter.of(context).go('/profile');
          }
        },
      ),
    );
  }
}
