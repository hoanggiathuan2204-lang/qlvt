import 'package:flutter/material.dart';

/// Stub for Web - không dùng dart:io
Widget buildImageWidget(
  String imagePath, {
  double? width,
  double? height,
  BoxFit? fit,
}) {
  return Container(
    color: Colors.grey[200],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Ảnh: $imagePath',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

/// Trên web không dùng InteractiveViewer với File
Widget buildInteractiveImage(String imagePath) {
  return buildImageWidget(imagePath);
}
