import 'dart:io';

import 'package:flutter/material.dart';

/// Hiển thị ảnh từ file path (native only)
Widget buildImageWidget(
  String imagePath, {
  double? width,
  double? height,
  BoxFit? fit,
}) {
  final file = File(imagePath);
  return Image.file(
    file,
    width: width,
    height: height,
    fit: fit ?? BoxFit.cover,
  );
}

/// Hiển thị ảnh có thể phóng to
Widget buildInteractiveImage(String imagePath) {
  return InteractiveViewer(child: Image.file(File(imagePath)));
}
