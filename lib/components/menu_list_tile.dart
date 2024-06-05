import 'package:flutter/material.dart';
import 'package:jamugo/api/menu/menu.dart';
import 'package:jamugo/components/cart_item_counter.dart';
import 'package:intl/intl.dart';

class MenuListTile extends StatelessWidget {
  final Menu menu;
  final int quantity;
  final Function onAdd;
  final Function onRemove;
  final String role;

  const MenuListTile({
    Key? key,
    required this.menu,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    required this.role,
  }) : super(key: key);

  String _formatPrice(double price) {
    final formatCurrency = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: NetworkImage(menu.imageUrl),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatPrice(menu.price),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  if (role == 'customer')
                    CartItemCounter(
                      quantity: quantity,
                      onAdd: () => onAdd(),
                      onRemove: () => onRemove(),
                    ),
                ],
              ),
            ),
            if (role != 'customer')
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.green),
                    onPressed: () {
                      // Add your logic for editing the menu here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Add your logic for deleting the menu here
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
