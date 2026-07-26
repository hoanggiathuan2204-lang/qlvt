import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/delivery_model.dart';

class DeliveryDialog extends StatefulWidget {
  final String productName;
  final int quantity;

  const DeliveryDialog({
    super.key,
    required this.productName,
    required this.quantity,
  });

  @override
  State<DeliveryDialog> createState() => _DeliveryDialogState();
}

class _DeliveryDialogState extends State<DeliveryDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController tenSPController;

  late final TextEditingController soKienController;

  final diaChiController = TextEditingController();

  final nguoiBocController = TextEditingController();

  final taiXeController = TextEditingController();

  final bienSoController = TextEditingController();

  final ghiChuController = TextEditingController();

  String? imagePath;

  @override
  void initState() {
    super.initState();

    tenSPController = TextEditingController(text: widget.productName);

    soKienController = TextEditingController(text: widget.quantity.toString());
  }

  @override
  void dispose() {
    tenSPController.dispose();
    soKienController.dispose();
    diaChiController.dispose();
    nguoiBocController.dispose();
    taiXeController.dispose();
    bienSoController.dispose();
    ghiChuController.dispose();
    super.dispose();
  }

  InputDecoration input(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Không được để trống";
    }
    return null;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) return;

    final source = File(result.files.single.path!);

    final appFolder = await getApplicationDocumentsDirectory();

    final imageFolder = Directory(p.join(appFolder.path, "delivery_images"));

    if (!await imageFolder.exists()) {
      await imageFolder.create(recursive: true);
    }

    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${p.basename(source.path)}";

    final target = File(p.join(imageFolder.path, fileName));

    await source.copy(target.path);

    setState(() {
      imagePath = target.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Phiếu giao hàng"),

      content: SizedBox(
        width: 550,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: tenSPController,
                  readOnly: true,
                  decoration: input("Tên sản phẩm"),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: soKienController,
                  readOnly: true,
                  decoration: input("Số kiện"),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: diaChiController,
                  decoration: input("Địa chỉ giao"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: nguoiBocController,
                  decoration: input("Người bốc hàng"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: taiXeController,
                  decoration: input("Tài xế"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: bienSoController,
                  decoration: input("Biển số xe"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: ghiChuController,
                  maxLines: 3,
                  decoration: input("Ghi chú"),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Chọn ảnh"),
                    ),

                    const SizedBox(width: 10),

                    if (imagePath != null)
                      const Text(
                        "Đã chọn ảnh",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 15),

                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: imagePath == null
                      ? const Center(child: Text("Chưa có ảnh"))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Hủy"),
        ),

        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.pop(
              context,
              DeliveryModel(
                id: 0,
                tenSanPham: widget.productName,
                soKien: widget.quantity,
                diaChiGiao: diaChiController.text.trim(),
                nguoiBocHang: nguoiBocController.text.trim(),
                taiXe: taiXeController.text.trim(),
                bienSoXe: bienSoController.text.trim(),
                thoiGian: DateTime.now(),
                ghiChu: ghiChuController.text.trim(),
                imagePath: imagePath,
              ),
            );
          },
          child: const Text("Xác nhận giao hàng"),
        ),
      ],
    );
  }
}
