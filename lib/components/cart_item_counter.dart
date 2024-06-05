import 'package:flutter/material.dart';

class CartItemCounter extends StatelessWidget {
  final int quantity;
  final Function onAdd;
  final Function onRemove;

  const CartItemCounter({
    Key? key,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove, color: Colors.red),
          onPressed: quantity > 0 ? () => onRemove() : null,
        ),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.green),
          onPressed: () => onAdd(),
        ),
      ],
    );
  }
}
