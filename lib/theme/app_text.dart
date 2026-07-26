import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppText {
  AppText._();

  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle subTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(fontSize: 15, color: AppColors.text);

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    color: AppColors.subText,
  );

  static const TextStyle menu = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
