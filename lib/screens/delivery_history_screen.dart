import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/delivery_model.dart';
import '../services/firestore_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_header.dart';
import '../utils/image_utils.dart' as img_utils;
import '../widgets/delivery_dialog.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  final bool showSidebar;
  final VoidCallback? onMenuTap;
  const DeliveryHistoryScreen({
    super.key,
    this.showSidebar = true,
    this.onMenuTap,
  });

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  final controller = AppData.deliveryController;
  final TextEditingController searchController = TextEditingController();
  final Stream<List<DeliveryModel>> _deliveryStream =
      FirestoreDataService.streamDeliveries();
  StreamSubscription<List<DeliveryModel>>? _deliverySub;
  List<DeliveryModel> _allDeliveries = [];
  List<DeliveryModel> deliveries = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _deliverySub = _deliveryStream.listen(
      (list) {
        if (!mounted) return;
        setState(() {
          _allDeliveries = list;
          deliveries = _filterDeliveries(_allDeliveries, _searchQuery);
        });
      },
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải lịch sử giao hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _deliverySub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  List<DeliveryModel> _filterDeliveries(
    List<DeliveryModel> list,
    String query,
  ) {
    if (query.trim().isEmpty) return list;
    final key = query.toLowerCase();
    return list.where((item) {
      return item.tenSanPham.toLowerCase().contains(key) ||
          item.taiXe.toLowerCase().contains(key) ||
          item.bienSoXe.toLowerCase().contains(key) ||
          item.diaChiGiao.toLowerCase().contains(key);
    }).toList();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    setState(() {
      deliveries = _filterDeliveries(_allDeliveries, _searchQuery);
    });
  }

  Future<void> addDelivery() async {
    final result = await showDialog<DeliveryModel>(
      context: context,
      builder: (_) => const DeliveryDialog(productName: "", quantity: 0),
    );

    if (result == null) return;

    await controller.addDelivery(result);

    await _refreshList();
  }

  Future<void> deleteDelivery(DeliveryModel delivery) async {
    await controller.deleteDelivery(delivery);

    await _refreshList();
  }

  Future<void> _refreshList() async {
    if (!mounted) return;
    setState(() {
      deliveries = _filterDeliveries(_allDeliveries, _searchQuery);
    });
  }

  Widget info(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text("$title : $value", style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

  Widget imageWidget(DeliveryModel item) {
    if (item.imagePath == null || item.imagePath!.isEmpty) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => Dialog(
            child: kIsWeb
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Ảnh: ${item.imagePath}'),
                  )
                : img_utils.buildInteractiveImage(item.imagePath!),
          ),
        );
      },
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: kIsWeb
            ? Center(child: Text('Ảnh: ${item.imagePath}'))
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: img_utils.buildImageWidget(
                  item.imagePath!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget card(DeliveryModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.tenSanPham,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const Divider(),

            info(Icons.inventory_2, "Số kiện", item.soKien.toString()),

            const SizedBox(height: 8),

            info(Icons.person, "Người bốc", item.nguoiBocHang),

            const SizedBox(height: 8),

            info(Icons.drive_eta, "Tài xế", item.taiXe),

            const SizedBox(height: 8),

            info(Icons.local_shipping, "Biển số", item.bienSoXe),

            const SizedBox(height: 8),

            info(Icons.location_on, "Địa chỉ", item.diaChiGiao),

            const SizedBox(height: 8),

            info(
              Icons.access_time,
              "Thời gian",
              item.thoiGian.toString().substring(0, 16),
            ),

            if (item.ghiChu.isNotEmpty) ...[
              const SizedBox(height: 8),

              info(Icons.note, "Ghi chú", item.ghiChu),
            ],

            if (item.imagePath != null && item.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 15),

              const Text(
                "Ảnh hàng hóa",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              imageWidget(item),
            ],

            const SizedBox(height: 15),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await deleteDelivery(item);
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text("Xóa", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: TextField(
            controller: searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: "Tìm theo sản phẩm hoặc tài xế",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: deliveries.isEmpty
              ? const Center(child: Text("Chưa có phiếu giao hàng"))
              : ListView.builder(
                  itemCount: deliveries.length,
                  itemBuilder: (context, index) {
                    return card(deliveries[index]);
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showSidebar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lịch sử giao hàng')),
        body: buildContent(),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DashboardHeader(
            title: 'Lịch sử giao hàng',
            userName: 'Administrator',
            onMenuTap: widget.onMenuTap,
          ),
          Expanded(child: buildContent()),
        ],
      ),
    );
  }
}
