import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.validator,
  });

  Widget _buildTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: MaterialTextField(
        keyboardType: keyboardType,
        labelText: label,
        textInputAction: TextInputAction.next,
        controller: controller,
        validator: validator,
        theme: BorderlessTextTheme(
          radius: 0,
          errorStyle: const TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w700,
          ),
          fillColor: Colors.transparent,
          enabledColor: Colors.black,
          focusedColor: Colors.black,
          floatingLabelStyle: const TextStyle(color: Colors.black),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTextField();
  }
}
