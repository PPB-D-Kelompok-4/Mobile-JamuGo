// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamugo/api/cart/cart.dart';
import 'package:jamugo/components/cart_item_counter.dart';
import 'package:intl/intl.dart';
import 'package:jamugo/api/menu/menu.dart';
import 'package:jamugo/api/order/order.dart';

class CartDetailPage extends StatefulWidget {
  const CartDetailPage({super.key});

  @override
  State<CartDetailPage> createState() => _CartDetailPageState();
}

class _CartDetailPageState extends State<CartDetailPage> {
  Future<CartResponse>? cartFuture;
  Map<int, int> quantities = {};
  Map<int, Future<Menu>> menuDetails = {};
  double discount = 0.0;

  @override
  void initState() {
    super.initState();
    cartFuture = CartApi.getCartByUser();
  }

  String _formatPrice(double price) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }

  double _calculateTotal(List<dynamic> items) {
    double total = items.fold(0, (sum, item) {
      return sum +
          (double.parse(item['price'].toString())) * (item['quantity'] as int);
    });
    return total - discount;
  }

  Future<void> _deleteCartItem(int itemId) async {
    try {
      await CartApi.deleteCartItem(itemId);
      Fluttertoast.showToast(
        msg: 'Item deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      setState(() {
        cartFuture = CartApi.getCartByUser();
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to delete item: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _updateCartItem(int menuPkid, int quantity) async {
    try {
      await CartApi.createOrUpdateCartItem(
        menuPkid: menuPkid,
        quantity: quantity,
      );
      Fluttertoast.showToast(
        msg: 'Cart updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      setState(() {
        cartFuture = CartApi.getCartByUser();
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to update cart: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _createOrder() async {
    try {
      final response = await OrderApi.createOrder();
      if (response.isSuccess) {
        Fluttertoast.showToast(
          msg: 'Order created successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        GoRouter.of(context).go('/order');
        GoRouter.of(context).push('/order_detail', extra: response.orderId);
        setState(() {
          cartFuture = CartApi.getCartByUser();
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to create order: ${response.message}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to create order: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _refreshCart() async {
    setState(() {
      cartFuture = CartApi.getCartByUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Keranjang Anda',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        ),
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCart,
        child: FutureBuilder<CartResponse>(
          future: cartFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.data == null) {
              return const Center(
                child: Text('No items in cart'),
              );
            } else {
              final items = snapshot.data!.data!['items'] as List<dynamic>;
              final totalAmount = _calculateTotal(items);

              return Stack(
                children: [
                  ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final itemId = item['pkid'];
                      final menuPkid = item['menu_pkid'];
                      final quantity = quantities[itemId] ?? item['quantity'];
                      final price = double.parse(item['price'].toString());

                      if (!menuDetails.containsKey(menuPkid)) {
                        menuDetails[menuPkid] = CartApi.getMenuById(menuPkid);
                      }

                      return FutureBuilder<Menu>(
                        future: menuDetails[menuPkid],
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
                            final menuName = menuSnapshot.data!.name;
                            final menuImageUrl = menuSnapshot.data!.imageUrl;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
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
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (menuImageUrl.isNotEmpty)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            menuImageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              menuName,
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              _formatPrice(price),
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 10),
                                            CartItemCounter(
                                              quantity: quantity,
                                              onAdd: () {
                                                setState(() {
                                                  quantities[itemId] =
                                                      quantity + 1;
                                                });
                                                _updateCartItem(
                                                    menuPkid, quantity + 1);
                                              },
                                              onRemove: () {
                                                if (quantity > 0) {
                                                  setState(() {
                                                    quantities[itemId] =
                                                        quantity - 1;
                                                  });
                                                  _updateCartItem(
                                                      menuPkid, quantity - 1);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteCartItem(itemId),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                      onPressed: () {
                        _createOrder();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _formatPrice(totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
