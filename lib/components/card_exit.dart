import 'package:flutter/material.dart';

class CardExit extends StatelessWidget {
  final Function onConfirm;
  final Function onCancel;

  const CardExit({required this.onConfirm, required this.onCancel, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Exit'),
      content: const Text('Are you sure you want to exit the app?'),
      actions: [
        TextButton(
          onPressed: () => onCancel(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => onConfirm(),
          child: const Text('Exit'),
        ),
      ],
    );
  }
}
