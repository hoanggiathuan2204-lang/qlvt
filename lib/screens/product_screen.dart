import 'package:flutter/material.dart';

import '../data/app_data.dart';

import '../models/product_model.dart';
import '../models/delivery_model.dart';

import '../widgets/product_card.dart';
import '../widgets/product_dialog.dart';
import '../widgets/delivery_dialog.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final controller = AppData.productController;

  final deliveryController = AppData.deliveryController;

  final TextEditingController searchController = TextEditingController();

  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  //------------------------------------
  // Load danh sách
  //------------------------------------
  Future<void> refreshList() async {
    try {
      products = await controller.search(searchController.text);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải thành phẩm: $e'), backgroundColor: Colors.red),
      );
    }
  }

  //------------------------------------
  // Thêm
  //------------------------------------
  Future<void> addProduct() async {
    final result = await showDialog<ProductModel>(
      context: context,
      builder: (_) => const ProductDialog(),
    );

    if (!mounted || result == null) return;

    await controller.addProduct(result);

    if (!mounted) return;
    await refreshList();
  }

  //------------------------------------
  // Sửa
  //------------------------------------
  Future<void> editProduct(ProductModel product) async {
    final result = await showDialog<ProductModel>(
      context: context,
      builder: (_) => ProductDialog(product: product),
    );

    if (!mounted || result == null) return;

    await controller.updateProduct(result);

    if (!mounted) return;
    await refreshList();
  }

  //------------------------------------
  // Xóa
  //------------------------------------
  Future<void> deleteProduct(ProductModel product) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Xóa thành phẩm"),
            content: Text("Bạn có chắc muốn xóa\n${product.tenSanPham} ?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(false);
                },
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(true);
                },
                child: const Text("Xóa"),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted) return;

    if (!ok) return;

    await controller.deleteProduct(product);

    await refreshList();
  }

  //------------------------------------
  // Nhập kho
  //------------------------------------
  Future<void> importProduct(ProductModel product) async {
    final qtyController = TextEditingController();

    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Nhập thành phẩm\n${product.tenSanPham}"),
            content: TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số kiện nhập",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(false),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(true),
                child: const Text("Lưu"),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !ok) return;

    final qty = int.tryParse(qtyController.text.trim()) ?? 0;

    if (qty <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Số kiện phải lớn hơn 0")));
      return;
    }

    await controller.importProduct(product, qty);

    if (!mounted) return;
    await refreshList();
  }

  //------------------------------------
  // Xuất thành phẩm
  //------------------------------------
  Future<void> exportProduct(ProductModel product) async {
    final qtyController = TextEditingController();

    final ok =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Xuất thành phẩm\n${product.tenSanPham}"),
            content: TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Số kiện xuất",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(false),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(true),
                child: const Text("Tiếp tục"),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !ok) return;

    final qty = int.tryParse(qtyController.text.trim()) ?? 0;

    if (qty <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Số kiện phải lớn hơn 0")));
      return;
    }

    final success = await controller.exportProduct(product, qty);

    if (!mounted) return;
    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Không đủ số kiện")));
      return;
    }

    final DeliveryModel? delivery = await showDialog<DeliveryModel>(
      context: context,
      builder: (_) =>
          DeliveryDialog(productName: product.tenSanPham, quantity: qty),
    );

    if (!mounted) return;

    if (delivery != null) {
      deliveryController.addDelivery(delivery);
    }

    if (!mounted) return;
    await refreshList();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Xuất thành phẩm thành công")));
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              onChanged: (_) => refreshList(),
              decoration: InputDecoration(
                hintText: "Tìm kiếm thành phẩm",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          const Text(
                            "Tổng sản phẩm",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<int>(
                            future: controller.totalProduct(),
                            builder: (context, snapshot) {
                              return Text(
                                "${snapshot.data ?? 0}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          const Text(
                            "Tổng số kiện",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<int>(
                            future: controller.totalPackage(),
                            builder: (context, snapshot) {
                              return Text(
                                "${snapshot.data ?? 0}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Chưa có thành phẩm",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final item = products[index];
                      return ProductCard(
                        product: item,
                        onEdit: () => editProduct(item),
                        onDelete: () => deleteProduct(item),
                        onImport: () => importProduct(item),
                        onExport: () => exportProduct(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
