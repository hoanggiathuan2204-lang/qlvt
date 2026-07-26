import 'package:flutter/material.dart';

import '../models/material_model.dart';
import '../services/auth_service.dart';

class MaterialCard extends StatelessWidget {
  final MaterialModel material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onImport;
  final VoidCallback onExport;

  const MaterialCard({
    super.key,
    required this.material,
    required this.onEdit,
    required this.onDelete,
    required this.onImport,
    required this.onExport,
  });

  Color getStatusColor() {
    if (material.soLuongTon == 0) {
      return Colors.red;
    }

    if (material.soLuongTon <= material.mucCanhBao) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String getStatusText() {
    if (material.soLuongTon == 0) {
      return "Hết hàng";
    }

    if (material.soLuongTon <= material.mucCanhBao) {
      return "Sắp hết";
    }

    return "Còn hàng";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: getStatusColor(),
                  child: const Icon(Icons.inventory_2, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    material.tenVatTu,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  backgroundColor: getStatusColor(),
                  label: Text(
                    getStatusText(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text("Mã: ${material.maVatTu}"),
            Text("Nhóm: ${material.nhomVatTu}"),
            Text("Đơn vị: ${material.donViTinh}"),
            Text("Tồn kho: ${material.soLuongTon}"),
            Text("Cảnh báo: ${material.mucCanhBao}"),
            if (AuthService.instance.canViewUnitPrice)
              Text("Giá nhập: ${material.giaNhap.toStringAsFixed(0)} VNĐ"),
            Text("Nhà cung cấp: ${material.nhaCungCap}"),

            const Divider(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  tooltip: "Nhập kho",
                  icon: const Icon(Icons.add_box, color: Colors.green),
                  onPressed: onImport,
                ),
                IconButton(
                  tooltip: "Xuất kho",
                  icon: const Icon(
                    Icons.indeterminate_check_box,
                    color: Colors.orange,
                  ),
                  onPressed: onExport,
                ),
                IconButton(
                  tooltip: "Sửa",
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: "Xóa",
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
