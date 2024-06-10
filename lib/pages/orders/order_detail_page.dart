import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
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
  String role = '';
  int currentStep = 0;
  bool isCancel = false;
  Map<int, Future<Menu>> menuDetails = {};

  @override
  void initState() {
    super.initState();
    orderDetailFuture = OrderApi.getOrderById(widget.orderId);
    _getRole();
    orderDetailFuture.then((response) {
      if (response.data != null) {
        _getStep(response.data!.status);
      }
      if (response.data!.status == 'cancelled') {
        setState(() {
          isCancel = true;
        });
      }
    });
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
    final format = DateFormat('dd MMMM yyyy HH:mm');
    return format.format(dateTime);
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'order_placed':
        return 'Order Placed';
      case 'preparing':
        return 'Preparing';
      case 'ready_for_pickup':
        return 'Ready for Pickup';
      case 'picked_up':
        return 'Picked Up';
      case 'cancelled':
        return 'Cancelled';
      default:
        return '';
    }
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

  void _getStep(String status) {
    if (status == 'pending') {
      setState(() {
        currentStep = 0;
      });
    } else if (status == 'process') {
      setState(() {
        currentStep = 1;
      });
    } else if (status == 'completed' || status == 'cancelled') {
      setState(() {
        currentStep = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order #${widget.orderId}',
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
                      Center(
                        child: Column(
                          children: [
                            IconStepper(
                              enableStepTapping: false,
                              enableNextPreviousButtons: false,
                              icons: [
                                const Icon(Icons.access_time_filled_sharp),
                                const Icon(Icons.local_drink),
                                isCancel
                                    ? const Icon(Icons.cancel)
                                    : const Icon(Icons.check_circle)
                              ],
                              activeStep: currentStep,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text('Pending'),
                                const Text('Process'),
                                Text(isCancel ? 'Cancelled' : 'Completed'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (order.status == 'process')
                        Text(
                          'Status: ${_formatStatus(order.orderStatus!.status)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
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
                if ((role == 'customer' && order.status == 'pending') ||
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
