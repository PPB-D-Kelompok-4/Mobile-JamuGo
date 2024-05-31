import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_jamugo/api/menu/menu.dart';
import 'package:intl/intl.dart';

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
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JamuGo"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Menu>>(
        future: menus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
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
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image(
                      image: NetworkImage(menu.imageUrl),
                      height: 200,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  title: Text(menu.name),
                  trailing: Text(_formatPrice(menu.price)),
                );
              },
            );
          }
        },
      ),
    );
  }
}
