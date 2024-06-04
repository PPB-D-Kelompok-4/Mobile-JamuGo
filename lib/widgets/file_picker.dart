import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? image;
  final String? initialImageUrl;
  final VoidCallback getImage;

  const ImagePickerWidget({
    super.key,
    required this.image,
    this.initialImageUrl,
    required this.getImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (image != null)
          Image.file(image!, height: 200, width: 200, fit: BoxFit.cover)
        else if (initialImageUrl != null)
          Image.network(initialImageUrl!,
              height: 200, width: 200, fit: BoxFit.cover)
        else
          Container(
            height: 200,
            width: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.image, size: 100, color: Colors.grey),
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}
