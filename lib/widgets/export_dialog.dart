import 'package:flutter/material.dart';

import '../models/material_model.dart';

class ExportDialog extends StatefulWidget {
  final MaterialModel material;

  const ExportDialog({super.key, required this.material});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final _formKey = GlobalKey<FormState>();
  final soLuongController = TextEditingController();
  final nguoiXuatController = TextEditingController();
  final lyDoController = TextEditingController();
  final ghiChuController = TextEditingController();

  @override
  void dispose() {
    soLuongController.dispose();
    nguoiXuatController.dispose();
    lyDoController.dispose();
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
          const Icon(Icons.output, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Xuất kho — ${widget.material.tenVatTu}',
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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2, color: Colors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.material.tenVatTu,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            'Mã: ${widget.material.maVatTu} | Tồn kho: ${widget.material.soLuongTon} ${widget.material.donViTinh}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: soLuongController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final err = _positiveInt(v);
                  if (err != null) return err;
                  final n = int.parse(v!.trim());
                  if (n > widget.material.soLuongTon) {
                    return 'Vượt quá tồn kho (${widget.material.soLuongTon})';
                  }
                  return null;
                },
                decoration:
                    _input('Số lượng xuất *', Icons.remove_circle_outline),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nguoiXuatController,
                validator: _required,
                decoration: _input('Người xuất kho *', Icons.person),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lyDoController,
                validator: _required,
                decoration: _input('Lý do xuất *', Icons.info_outline),
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
          label: const Text('Xác nhận xuất kho'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'soLuong': int.parse(soLuongController.text.trim()),
              'nguoiXuat': nguoiXuatController.text.trim(),
              'lyDo': lyDoController.text.trim(),
              'ghiChu': ghiChuController.text.trim(),
            });
          },
        ),
      ],
    );
  }
}
