import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:jamugo/api/order/order.dart';
import 'package:jamugo/api/menu/menu.dart';
import 'package:jamugo/utils/shared_preferences.dart';
import 'package:intl/intl.dart';

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
    _getRole();
    _refreshOrderDetail();
  }

  Future<void> _refreshOrderDetail() async {
    setState(() {
      orderDetailFuture = OrderApi.getOrderById(widget.orderId);
      orderDetailFuture.then((response) {
        if (response.data != null) {
          _getStep(response.data!.status);
        }
        if (response.data!.orderStatus!.status == 'cancelled' ||
            response.data!.status == 'cancelled') {
          setState(() {
            isCancel = true;
          });
        }
      });
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

  double _calculateTax(double totalPrice) {
    return totalPrice / 1.11 * 0.11;
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

  Future<void> _cancelOrderByAdmin(int orderId) async {
    try {
      final response = await OrderApi.cancelOrderByAdmin(orderId);
      if (response.isSuccess) {
        _showToast('Order cancelled successfully',
            backgroundColor: Colors.green);
        _refreshOrderDetail();
      } else {
        _showToast('Failed to cancel order: ${response.message}');
      }
    } catch (error) {
      _showToast('Failed to cancel order: $error');
    }
  }

  void _getStep(String status) {
    switch (status) {
      case 'order_placed':
        setState(() {
          currentStep = 0;
        });
        break;
      case 'preparing':
        setState(() {
          currentStep = 1;
        });
        break;
      case 'ready_for_pickup':
        setState(() {
          currentStep = 2;
        });
        break;
      case 'picked_up':
        setState(() {
          currentStep = 3;
        });
        break;
      case 'cancelled':
        setState(() {
          currentStep = 3;
        });
        break;
      default:
        setState(() {
          currentStep = 0;
        });
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    try {
      final response = await OrderApi.cancelOrder(orderId);
      if (response.isSuccess) {
        _showToast('Order canceled successfully',
            backgroundColor: Colors.green);
        _refreshOrderDetail();
      } else {
        _showToast('Failed to cancel order: ${response.message}');
      }
    } catch (error) {
      _showToast('Failed to cancel order: $error');
    }
  }

  Future<void> _processOrder(int orderId) async {
    try {
      final response = await OrderApi.processOrder(orderId);
      if (response.isSuccess) {
        _showToast('Order processed successfully',
            backgroundColor: Colors.green);
        _refreshOrderDetail();
      } else {
        _showToast('Failed to process order: ${response.message}');
      }
    } catch (error) {
      _showToast('Failed to process order: $error');
    }
  }

  Future<void> _finishOrder(int orderId) async {
    try {
      final response = await OrderApi.finishOrder(orderId);
      if (response.isSuccess) {
        _showToast('Order finished successfully',
            backgroundColor: Colors.green);
        _refreshOrderDetail();
      } else {
        _showToast('Failed to finish order: ${response.message}');
      }
    } catch (error) {
      _showToast('Failed to finish order: $error');
    }
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    try {
      final response = await OrderApi.updateOrderStatus(orderId, status);
      if (response.isSuccess) {
        _showToast('Order status updated to $status',
            backgroundColor: Colors.green);
        _refreshOrderDetail();
      } else {
        _showToast('Failed to update status: ${response.message}');
      }
    } catch (error) {
      _showToast('Failed to update status: $error');
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
      body: RefreshIndicator(
        onRefresh: _refreshOrderDetail,
        child: FutureBuilder<OrderDetailResponse>(
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
              final tax = _calculateTax(order.totalPrice);
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              IconStepper(
                                stepPadding: 0,
                                lineLength: 40,
                                enableStepTapping: false,
                                enableNextPreviousButtons: false,
                                icons: [
                                  const Icon(Icons.notes_outlined),
                                  const Icon(Icons.coffee_maker_rounded),
                                  const Icon(Icons.shopping_bag),
                                  isCancel
                                      ? const Icon(Icons.cancel)
                                      : const Icon(Icons.check_circle),
                                ],
                                activeStep: currentStep,
                                lineColor: Colors.green,
                                activeStepColor: Colors.green,
                                stepColor: Colors.white,
                                stepRadius: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: const Text(
                                      'Order Placed',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Preparing',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Text(
                                      'Ready For Pickup',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      isCancel ? 'Cancelled' : 'Picked Up',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                      child:
                                          Text('Error: ${menuSnapshot.error}'),
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
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax (11%)'),
                            Text(_formatPrice(tax)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Price'),
                            Text(
                              _formatPrice(order.totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Order Details',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order ID'),
                            Text(order.pkid.toString()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Order Date'),
                            Text(_formatDate(order.createdDate)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Ordered By'),
                            Text(order.createdBy),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (role == 'admin' &&
                      order.status != 'completed' &&
                      order.status != 'cancelled')
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                _cancelOrderByAdmin(order.pkid);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Cancel Order',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                _updateOrderStatus(order.pkid, 'preparing');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Update to Preparing',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                _updateOrderStatus(
                                    order.pkid, 'ready_for_pickup');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Update to Ready for Pickup',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                _updateOrderStatus(order.pkid, 'picked_up');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Update to Picked Up',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (role == 'admin' && order.status == 'pending')
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _processOrder(order.pkid);
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
                              'Process Order',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (role == 'admin' && order.status == 'process')
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _finishOrder(order.pkid);
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
                              'Finish Order',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (role == 'customer' && order.status == 'pending')
                    Positioned(
                      bottom: 20,
                      left: 20,
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
                  if (role == 'customer' && order.status == 'pending')
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          GoRouter.of(context).push(
                            '/transaction',
                            extra: {
                              'orderId': order.pkid,
                              'orderPriceTotal': _formatPrice(order.totalPrice),
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                        ),
                        child: const Text(
                          'Pay',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
