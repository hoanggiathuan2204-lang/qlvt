import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductDialog extends StatefulWidget {
  final ProductModel? product;

  const ProductDialog({super.key, this.product});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController maController;
  late final TextEditingController tenController;
  late final TextEditingController donViController;
  late final TextEditingController soKienController;
  late final TextEditingController diaChiController;

  @override
  void initState() {
    super.initState();

    final item = widget.product;

    maController = TextEditingController(text: item?.maSanPham ?? "");

    tenController = TextEditingController(text: item?.tenSanPham ?? "");

    donViController = TextEditingController(text: item?.donVi ?? "");

    soKienController = TextEditingController(
      text: item?.soKien.toString() ?? "0",
    );

    diaChiController = TextEditingController(text: item?.diaChiLapRap ?? "");
  }

  @override
  void dispose() {
    maController.dispose();
    tenController.dispose();
    donViController.dispose();
    soKienController.dispose();
    diaChiController.dispose();
    super.dispose();
  }

  InputDecoration input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Không được để trống";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.product == null ? "Thêm thành phẩm" : "Cập nhật thành phẩm",
      ),

      content: SizedBox(
        width: 450,

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: maController,
                  validator: validate,
                  decoration: input("Mã sản phẩm", Icons.qr_code),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: tenController,
                  validator: validate,
                  decoration: input("Tên sản phẩm", Icons.inventory),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: donViController,
                  validator: validate,
                  decoration: input("Đơn vị", Icons.straighten),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: soKienController,
                  keyboardType: TextInputType.number,
                  validator: validate,
                  decoration: input("Số kiện", Icons.all_inbox),
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: diaChiController,
                  validator: validate,
                  maxLines: 2,
                  decoration: input("Địa chỉ lắp ráp", Icons.location_on),
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text("Hủy"),
        ),

        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: Text(widget.product == null ? "Thêm" : "Cập nhật"),
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.of(context, rootNavigator: true).pop(
              ProductModel(
                id: widget.product?.id ?? 0,
                maSanPham: maController.text.trim(),
                tenSanPham: tenController.text.trim(),
                donVi: donViController.text.trim(),
                soKien: int.tryParse(soKienController.text) ?? 0,
                diaChiLapRap: diaChiController.text.trim(),
                ngayTao: widget.product?.ngayTao ?? DateTime.now(),
              ),
            );
          },
        ),
      ],
    );
  }
}
