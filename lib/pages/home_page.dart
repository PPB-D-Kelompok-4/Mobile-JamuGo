import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jamugo/api/menu/menu.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Menu>> menus;

  @override
  void initState() {
    super.initState();
    menus = _getMenus();
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

  String _formatPrice(double price) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              GoRouter.of(context).push('/cart');
            },
          ),
        ],
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Menu>>(
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
                return ListTile(
                  minVerticalPadding: 30,
                  leading: SizedBox(
                    height: 200,
                    width: 50,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image(
                        image: NetworkImage(menu.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(menu.name,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    _formatPrice(menu.price),
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      // TODO: Add to cart
                    },
                  ),
                  onTap: () {
                    // TODO: Show menu detail modal
                  },
                );
              },
            );
          }
        },
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
