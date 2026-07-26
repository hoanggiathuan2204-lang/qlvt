import 'package:flutter/material.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nhập kho")),
      body: const Center(
        child: Text("Màn hình Nhập kho", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}
