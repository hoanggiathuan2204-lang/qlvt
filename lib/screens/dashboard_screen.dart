import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/delivery_model.dart';
import '../models/material_model.dart';
import '../screens/delivery_history_screen.dart';
import '../screens/material_screen.dart';
import '../screens/product_screen.dart';
import '../screens/report_screen.dart';
import '../screens/supplier_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';

class DashboardScreen extends StatefulWidget {
  final bool showSidebar;
  const DashboardScreen({super.key, this.showSidebar = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedMenu = 0;

  int totalMaterial = 0;
  int totalProduct = 0;
  int totalSupplier = 0;
  int totalDelivery = 0;
  int warningCount = 0;
  int totalInventory = 0;

  List<MaterialModel> warningList = [];
  List<DeliveryModel> recentDeliveries = [];

  bool loading = true;

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  static String _fmtDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year} $h:$mi';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      totalMaterial = await AppData.materialController.totalMaterial();
      if (!mounted) return;
      setState(() {});

      totalProduct = await AppData.productController.totalProduct();
      if (!mounted) return;
      setState(() {});

      totalSupplier = await AppData.supplierController.total();
      if (!mounted) return;
      setState(() {});

      totalDelivery = await AppData.deliveryController.totalDelivery();
      if (!mounted) return;
      setState(() {});

      warningCount = await AppData.materialController.warningMaterial();
      if (!mounted) return;
      setState(() {});

      totalInventory = await AppData.materialController.totalInventory();
      if (!mounted) return;
      setState(() {});

      warningList = await AppData.materialController.warningList();
      if (!mounted) return;
      setState(() {});

      final all = await AppData.deliveryController.newest();
      if (!mounted) return;
      setState(() {
        recentDeliveries = all.take(5).toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải dữ liệu dashboard: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = _buildRightPanel();
    if (widget.showSidebar) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            DashboardSidebar(
              selectedIndex: selectedMenu,
              onSelect: (v) => setState(() => selectedMenu = v),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(backgroundColor: AppColors.background, body: content);
  }

  Widget _buildRightPanel() {
    switch (selectedMenu) {
      case 0:
        return _buildDashboard();
      case 1:
        return const MaterialScreen();
      case 2:
        return const SupplierScreen();
      case 3:
        return const ProductScreen();
      case 4:
        return const DeliveryHistoryScreen();
      case 5:
        return const ReportScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        DashboardHeader(title: 'Dashboard', userName: 'Administrator'),
        if (loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng quan hệ thống',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hệ thống quản lý vật tư - Công ty Cổ phần Ánh Dương',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Làm mới dữ liệu',
                          onPressed: _loadData,
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        DashboardCard(
                          title: 'Vật tư',
                          value: totalMaterial.toString(),
                          subTitle: 'Loại đang quản lý',
                          icon: Icons.inventory_2,
                          color: AppColors.blue,
                        ),
                        DashboardCard(
                          title: 'Tồn kho',
                          value: _fmt(totalInventory),
                          subTitle: 'Tổng số lượng',
                          icon: Icons.warehouse,
                          color: AppColors.green,
                        ),
                        DashboardCard(
                          title: 'Thành phẩm',
                          value: totalProduct.toString(),
                          subTitle: 'Trong kho',
                          icon: Icons.factory,
                          color: AppColors.orange,
                        ),
                        DashboardCard(
                          title: 'Nhà cung cấp',
                          value: totalSupplier.toString(),
                          subTitle: 'Đối tác',
                          icon: Icons.business,
                          color: AppColors.purple,
                        ),
                        DashboardCard(
                          title: 'Phiếu giao',
                          value: totalDelivery.toString(),
                          subTitle: 'Đã giao',
                          icon: Icons.local_shipping,
                          color: const Color(0xff0D4F8B),
                        ),
                        DashboardCard(
                          title: 'Cảnh báo',
                          value: warningCount.toString(),
                          subTitle: 'Vật tư thiếu hàng',
                          icon: Icons.warning_amber,
                          color: warningCount > 0
                              ? AppColors.danger
                              : AppColors.subText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _recentDeliveriesCard()),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _warningCard()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _recentDeliveriesCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(Icons.local_shipping, 'Giao hàng gần đây'),
          const SizedBox(height: 12),
          const Divider(),
          if (recentDeliveries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Chưa có phiếu giao hàng nào',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...recentDeliveries.map((d) => _deliveryTile(d)),
        ],
      ),
    );
  }

  Widget _deliveryTile(DeliveryModel d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0x1AF57C00),
            radius: 20,
            child: Icon(
              Icons.local_shipping,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.tenSanPham,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${d.soKien} kiện → ${d.diaChiGiao}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            _fmtDate(d.thoiGian),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _warningCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: warningCount > 0 ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Cảnh báo tồn kho',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (warningCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$warningCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          if (warningList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Tất cả vật tư đủ tồn kho!',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            )
          else
            ...warningList
                .take(6)
                .map(
                  (m) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.red, size: 10),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.tenVatTu,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Tồn: ${_fmt(m.soLuongTon)} | Cảnh báo: ${_fmt(m.mucCanhBao)} ${m.donViTinh}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CardTitle(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
