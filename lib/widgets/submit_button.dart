import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const SubmitButton(
      {super.key, required this.onPressed, this.buttonText = "Sign in"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: MediaQuery.of(context).size.width,
        height: 55,
        elevation: 2,
        color: Colors.green,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
