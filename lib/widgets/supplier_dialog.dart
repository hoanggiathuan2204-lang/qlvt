import 'package:flutter/material.dart';

import '../models/supplier_model.dart';

class SupplierDialog extends StatefulWidget {
  final SupplierModel? supplier;
  final String initialCode;

  const SupplierDialog({
    super.key,
    this.supplier,
    this.initialCode = '',
  });

  @override
  State<SupplierDialog> createState() => _SupplierDialogState();
}

class _SupplierDialogState extends State<SupplierDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController maController;
  late final TextEditingController tenController;
  late final TextEditingController diaChiController;
  late final TextEditingController sdtController;
  late final TextEditingController emailController;
  late final TextEditingController nguoiLienHeController;
  late final TextEditingController ghiChuController;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    maController = TextEditingController(text: s?.maNCC ?? widget.initialCode);
    tenController = TextEditingController(text: s?.tenNCC ?? '');
    diaChiController = TextEditingController(text: s?.diaChi ?? '');
    sdtController = TextEditingController(text: s?.soDienThoai ?? '');
    emailController = TextEditingController(text: s?.email ?? '');
    nguoiLienHeController =
        TextEditingController(text: s?.nguoiLienHe ?? '');
    ghiChuController = TextEditingController(text: s?.ghiChu ?? '');
  }

  @override
  void dispose() {
    maController.dispose();
    tenController.dispose();
    diaChiController.dispose();
    sdtController.dispose();
    emailController.dispose();
    nguoiLienHeController.dispose();
    ghiChuController.dispose();
    super.dispose();
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;

    return AlertDialog(
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit : Icons.add_business,
              color: const Color(0xff0D4F8B)),
          const SizedBox(width: 10),
          Text(isEdit ? 'Chỉnh sửa nhà cung cấp' : 'Thêm nhà cung cấp'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: maController,
                        validator: _required,
                        decoration:
                            _input('Mã nhà cung cấp *', Icons.qr_code),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: tenController,
                        validator: _required,
                        decoration:
                            _input('Tên nhà cung cấp *', Icons.business),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: diaChiController,
                  maxLines: 2,
                  decoration: _input('Địa chỉ', Icons.location_on),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: sdtController,
                        decoration:
                            _input('Số điện thoại', Icons.phone),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: emailController,
                        decoration: _input('Email', Icons.email),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nguoiLienHeController,
                  decoration:
                      _input('Người liên hệ', Icons.person),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ghiChuController,
                  maxLines: 3,
                  decoration: _input('Ghi chú', Icons.notes),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: Text(isEdit ? 'Cập nhật' : 'Thêm'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              SupplierModel(
                id: widget.supplier?.id ?? 0,
                maNCC: maController.text.trim(),
                tenNCC: tenController.text.trim(),
                diaChi: diaChiController.text.trim(),
                soDienThoai: sdtController.text.trim(),
                email: emailController.text.trim(),
                nguoiLienHe: nguoiLienHeController.text.trim(),
                ghiChu: ghiChuController.text.trim(),
                ngayTao: widget.supplier?.ngayTao ?? DateTime.now(),
              ),
            );
          },
        ),
      ],
    );
  }
}
