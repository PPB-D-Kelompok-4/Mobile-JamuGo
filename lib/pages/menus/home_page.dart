import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jamugo/api/menu/menu.dart';
import 'package:jamugo/api/cart/cart.dart';
import 'package:go_router/go_router.dart';
import 'package:jamugo/utils/shared_preferences.dart';
import 'package:jamugo/components/menu_list_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamugo/pages/menus/menu_detail_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Menu>> menus;
  String role = '';
  String name = '';
  Map<int, int> cartQuantities =
      {};

  @override
  void initState() {
    super.initState();
    menus = _getMenus();
    getUserData();
    _getCartData();
  }

  Future<void> getUserData() async {
    final getRole = await SharedPreferencesUtil.readData(key: 'role');
    final getName = await SharedPreferencesUtil.readData(key: 'name');
    setState(() {
      role = getRole ?? '';
      name = getName ?? '';
    });
  }

  Future<void> _getCartData() async {
    try {
      final response = await CartApi.getCartByUser();
      if (response.isSuccess && response.data != null) {
        final items = response.data!['items'] as List<dynamic>;
        for (var item in items) {
          cartQuantities[item['menu_pkid']] = item['quantity'];
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to get cart data: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<List<Menu>> _getMenus() async {
    try {
      final menus = await MenuApi.getAllMenus();
      return menus;
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to get menus: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return [];
    }
  }

  Future<void> _deleteMenu(int id) async {
    await MenuApi.deleteMenu(id);
    Fluttertoast.showToast(
      msg: 'Menu deleted successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    setState(() {
      menus = _getMenus();
    });
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this menu?'),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMenu(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshMenus() async {
    setState(() {
      menus = _getMenus();
    });
  }

  Future<void> _updateCart(int menuPkid, int quantity) async {
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
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to update cart: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showMenuDetailModal(BuildContext context, int menuId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: MenuDetailModal(menuId: menuId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Halo, $name',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400),
        ),
        actions: role == 'customer'
            ? [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    GoRouter.of(context)
                        .push('/cart');
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    GoRouter.of(context).push(
                      '/add_menu',
                      extra: _refreshMenus,
                    );
                  },
                ),
              ],
        backgroundColor: Colors.green,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMenus,
        child: FutureBuilder<List<Menu>>(
          future: menus,
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
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No menus available'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final menu = snapshot.data![index];
                  int quantity =
                      cartQuantities[menu.pkid] ?? 0;

                  return GestureDetector(
                    onTap: () => _showMenuDetailModal(context, menu.pkid),
                    child: MenuListTile(
                      menu: menu,
                      quantity: quantity,
                      onAdd: () {
                        setState(() {
                          quantity++;
                          cartQuantities[menu.pkid] = quantity;
                        });
                        _updateCart(menu.pkid, quantity);
                      },
                      onRemove: () {
                        setState(() {
                          if (quantity > 0) {
                            quantity--;
                            cartQuantities[menu.pkid] = quantity;
                          }
                        });
                        _updateCart(menu.pkid, quantity);
                      },
                      role: role,
                      refreshMenus: _refreshMenus,
                      showDeleteConfirmationDialog:
                          _showDeleteConfirmationDialog,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          } else if (index == 1) {
            GoRouter.of(context).go('/order');
          } else if (index == 2) {
            GoRouter.of(context).go('/profile');
          }
        },
      ),
    );
  }
}
