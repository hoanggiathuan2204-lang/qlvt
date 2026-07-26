import 'package:flutter/material.dart';

import '../models/material_model.dart';

class MaterialDialog extends StatefulWidget {
  final MaterialModel? material;

  const MaterialDialog({super.key, this.material});

  @override
  State<MaterialDialog> createState() => _MaterialDialogState();
}

class _MaterialDialogState extends State<MaterialDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController maController;
  late final TextEditingController tenController;
  late final TextEditingController nhomController;
  late final TextEditingController donViController;
  late final TextEditingController tonController;
  late final TextEditingController canhBaoController;
  late final TextEditingController giaController;
  late final TextEditingController nhaCCController;

  @override
  void initState() {
    super.initState();

    final item = widget.material;

    maController = TextEditingController(text: item?.maVatTu ?? "");

    tenController = TextEditingController(text: item?.tenVatTu ?? "");

    nhomController = TextEditingController(text: item?.nhomVatTu ?? "");

    donViController = TextEditingController(text: item?.donViTinh ?? "");

    tonController = TextEditingController(
      text: item?.soLuongTon.toString() ?? "0",
    );

    canhBaoController = TextEditingController(
      text: item?.mucCanhBao.toString() ?? "0",
    );

    giaController = TextEditingController(
      text: item?.giaNhap.toString() ?? "0",
    );

    nhaCCController = TextEditingController(text: item?.nhaCungCap ?? "");
  }

  @override
  void dispose() {
    maController.dispose();
    tenController.dispose();
    nhomController.dispose();
    donViController.dispose();
    tonController.dispose();
    canhBaoController.dispose();
    giaController.dispose();
    nhaCCController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.material == null ? "Thêm vật tư" : "Sửa vật tư"),

      content: SizedBox(
        width: 500,

        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextFormField(
                  controller: maController,
                  decoration: input("Mã vật tư"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: tenController,
                  decoration: input("Tên vật tư"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: nhomController,
                  decoration: input("Nhóm vật tư"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: donViController,
                  decoration: input("Đơn vị tính"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: tonController,
                  keyboardType: TextInputType.number,
                  decoration: input("Số lượng tồn"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: canhBaoController,
                  keyboardType: TextInputType.number,
                  decoration: input("Mức cảnh báo"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: giaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: input("Giá nhập"),
                  validator: requiredText,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: nhaCCController,
                  decoration: input("Nhà cung cấp"),
                  validator: requiredText,
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

        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            final material = MaterialModel(
              id: widget.material?.id ?? 0,
              maVatTu: maController.text.trim(),
              tenVatTu: tenController.text.trim(),
              nhomVatTu: nhomController.text.trim(),
              donViTinh: donViController.text.trim(),
              soLuongTon: int.tryParse(tonController.text) ?? 0,
              mucCanhBao: int.tryParse(canhBaoController.text) ?? 0,
              giaNhap: double.tryParse(giaController.text) ?? 0,
              nhaCungCap: nhaCCController.text.trim(),
            );

            Navigator.of(context, rootNavigator: true).pop(material);
          },
          child: Text(widget.material == null ? "Thêm" : "Cập nhật"),
        ),
      ],
    );
  }
}
