import 'package:flutter/material.dart';

import '../models/material_model.dart';

class ImportDialog extends StatefulWidget {
  final MaterialModel material;

  const ImportDialog({super.key, required this.material});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _formKey = GlobalKey<FormState>();
  final soLuongController = TextEditingController();
  final donGiaController = TextEditingController();
  final nguoiNhapController = TextEditingController();
  final ghiChuController = TextEditingController();

  @override
  void dispose() {
    soLuongController.dispose();
    donGiaController.dispose();
    nguoiNhapController.dispose();
    ghiChuController.dispose();
    super.dispose();
  }

  InputDecoration _input(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Không được để trống' : null;

  String? _positiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Không được để trống';
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return 'Phải là số nguyên dương';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.input, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nhập kho — ${widget.material.tenVatTu}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thông tin vật tư (readonly)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.material.tenVatTu,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Mã: ${widget.material.maVatTu} | Tồn: ${widget.material.soLuongTon} ${widget.material.donViTinh}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: soLuongController,
                      keyboardType: TextInputType.number,
                      validator: _positiveInt,
                      decoration: _input('Số lượng nhập *', Icons.add_box),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: donGiaController,
                      keyboardType: TextInputType.number,
                      decoration: _input('Đơn giá (VNĐ)', Icons.attach_money),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nguoiNhapController,
                validator: _required,
                decoration: _input('Người nhập kho *', Icons.person),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ghiChuController,
                maxLines: 2,
                decoration: _input('Ghi chú', Icons.notes),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Xác nhận nhập kho'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'soLuong': int.parse(soLuongController.text.trim()),
              'donGia':
                  double.tryParse(donGiaController.text.trim()) ?? 0,
              'nguoiNhap': nguoiNhapController.text.trim(),
              'ghiChu': ghiChuController.text.trim(),
            });
          },
        ),
      ],
    );
  }
}
