import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onImport;
  final VoidCallback onExport;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onImport,
    required this.onExport,
  });

  Color stockColor() {
    if (product.soKien == 0) {
      return Colors.red;
    }

    if (product.soKien <= 5) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String stockText() {
    if (product.soKien == 0) {
      return "Hết hàng";
    }

    if (product.soKien <= 5) {
      return "Sắp hết";
    }

    return "Còn hàng";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: stockColor(),
                  child: const Icon(Icons.inventory_2, color: Colors.white),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.tenSanPham,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        product.maSanPham,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                Chip(
                  backgroundColor: stockColor(),
                  label: Text(
                    stockText(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.straighten, size: 18),
                const SizedBox(width: 8),
                Text("Đơn vị: ${product.donVi}"),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.all_inbox, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Số kiện: ${product.soKien}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),

                Expanded(child: Text(product.diaChiLapRap)),
              ],
            ),

            const Divider(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  tooltip: "Nhập thành phẩm",
                  icon: const Icon(Icons.add_box, color: Colors.green),
                  onPressed: onImport,
                ),

                IconButton(
                  tooltip: "Xuất thành phẩm",
                  icon: const Icon(Icons.local_shipping, color: Colors.orange),
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
