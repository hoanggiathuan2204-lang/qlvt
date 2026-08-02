import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/export_model.dart';
import '../models/import_model.dart';
import '../models/material_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';

class ReportScreen extends StatefulWidget {
  final bool showSidebar;
  final VoidCallback? onMenuTap;
  const ReportScreen({super.key, this.showSidebar = true, this.onMenuTap});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int selectedMenu = 5;

  int totalMaterial = 0;
  int totalInventory = 0;
  int warningCount = 0;
  int totalProduct = 0;
  int totalDelivery = 0;
  int totalSupplier = 0;

  List<ImportModel> imports = [];
  List<ExportModel> exports = [];
  List<MaterialModel> warningMaterials = [];

  bool loading = true;

  // ─── Formatters (không cần intl) ───────────────────
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

  static String _fmtMoney(double amount) {
    if (amount <= 0) return '—';
    return '${_fmt(amount.toInt())} đ';
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final results = await Future.wait([
        AppData.materialController.totalMaterial(),
        AppData.materialController.totalInventory(),
        AppData.materialController.warningMaterial(),
        AppData.productController.totalProduct(),
        AppData.deliveryController.totalDelivery(),
        AppData.supplierController.total(),
        AppData.materialController.getImportHistory(),
        AppData.materialController.getExportHistory(),
        AppData.materialController.warningList(),
      ]);

      if (!mounted) return;
      setState(() {
        if (results.length >= 9) {
          totalMaterial = results[0] as int;
          totalInventory = results[1] as int;
          warningCount = results[2] as int;
          totalProduct = results[3] as int;
          totalDelivery = results[4] as int;
          totalSupplier = results[5] as int;
          imports = results[6] as List<ImportModel>;
          exports = results[7] as List<ExportModel>;
          warningMaterials = results[8] as List<MaterialModel>;
        } else {
          totalMaterial = 0;
          totalInventory = 0;
          warningCount = 0;
          totalProduct = 0;
          totalDelivery = 0;
          totalSupplier = 0;
          imports = [];
          exports = [];
          warningMaterials = [];
        }
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tải báo cáo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final Widget content = Column(
      children: [
        DashboardHeader(
          title: 'Báo cáo & Thống kê',
          userName: 'Administrator',
          onMenuTap: widget.onMenuTap,
        ),
        if (loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKpiRow(),
                  SizedBox(height: isMobile ? 12 : 20),
                  TabBar(
                    controller: _tab,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(icon: Icon(Icons.input), text: 'Nhập kho'),
                      Tab(icon: Icon(Icons.output), text: 'Xuất kho'),
                      Tab(icon: Icon(Icons.warning_amber), text: 'Cảnh báo'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        _buildImportTab(),
                        _buildExportTab(),
                        _buildWarningTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    if (widget.showSidebar) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final hasSpace = constraints.maxWidth >= AppSizes.sidebarWidth + 400;
          if (!hasSpace) {
            return Scaffold(backgroundColor: AppColors.background, body: content);
          }
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
        },
      );
    }

    return Scaffold(backgroundColor: AppColors.background, body: content);
  }

  // ─── KPI row ────────────────────────────────────────
  Widget _buildKpiRow() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _kpi(
          'Loại vật tư',
          totalMaterial.toString(),
          Icons.inventory_2,
          AppColors.blue,
        ),
        _kpi(
          'Tổng tồn kho',
          _fmt(totalInventory),
          Icons.warehouse,
          AppColors.green,
        ),
        _kpi(
          'Cảnh báo thiếu',
          warningCount.toString(),
          Icons.warning_amber,
          warningCount > 0 ? AppColors.danger : Colors.grey,
        ),
        _kpi(
          'Thành phẩm',
          totalProduct.toString(),
          Icons.factory,
          AppColors.orange,
        ),
        _kpi(
          'Phiếu giao',
          totalDelivery.toString(),
          Icons.local_shipping,
          AppColors.purple,
        ),
        _kpi(
          'Nhà cung cấp',
          totalSupplier.toString(),
          Icons.business,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) {
    final bg = Color.fromARGB(30, color.red, color.green, color.blue);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: isMobile ? (screenWidth - 40) / 2 : 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: bg,
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab nhập kho ───────────────────────────────────
  Widget _buildImportTab() {
    if (imports.isEmpty) {
      return _empty(Icons.input, 'Chưa có lịch sử nhập kho');
    }
    return _tableCard(
      headers: const [
        'Thời gian',
        'Vật tư',
        'Mã VT',
        'SL nhập',
        'Đơn giá',
        'Người nhập',
        'NCC',
      ],
      flexes: const [2, 3, 1, 1, 2, 2, 2],
      headerColor: Colors.blue.shade700,
      count: imports.length,
      label: 'nhập kho',
      builder: (i) {
        final r = imports[i];
        return _row(
          isEven: i % 2 == 0,
          bgEven: Colors.white,
          bgOdd: Colors.blue.shade50,
          cells: [
            _cell(_fmtDate(r.thoiGian), 2),
            _cell(r.tenVatTu, 3, bold: true, color: Colors.blue.shade800),
            _cell(r.maVatTu, 1),
            _cell('+${_fmt(r.soLuong)}', 1, bold: true, color: Colors.green),
            _cell(_fmtMoney(r.donGia), 2),
            _cell(r.nguoiNhap, 2),
            _cell(r.nhaCungCap.isEmpty ? '—' : r.nhaCungCap, 2),
          ],
        );
      },
    );
  }

  // ─── Tab xuất kho ───────────────────────────────────
  Widget _buildExportTab() {
    if (exports.isEmpty) {
      return _empty(Icons.output, 'Chưa có lịch sử xuất kho');
    }
    return _tableCard(
      headers: const [
        'Thời gian',
        'Vật tư',
        'Mã VT',
        'SL xuất',
        'Lý do',
        'Người xuất',
      ],
      flexes: const [2, 3, 1, 1, 2, 2],
      headerColor: Colors.orange.shade700,
      count: exports.length,
      label: 'xuất kho',
      builder: (i) {
        final r = exports[i];
        return _row(
          isEven: i % 2 == 0,
          bgEven: Colors.white,
          bgOdd: Colors.orange.shade50,
          cells: [
            _cell(_fmtDate(r.thoiGian), 2),
            _cell(r.tenVatTu, 3, bold: true, color: Colors.orange.shade800),
            _cell(r.maVatTu, 1),
            _cell('-${_fmt(r.soLuong)}', 1, bold: true, color: Colors.red),
            _cell(r.lyDo, 2),
            _cell(r.nguoiXuat, 2),
          ],
        );
      },
    );
  }

  // ─── Tab cảnh báo ───────────────────────────────────
  Widget _buildWarningTab() {
    if (warningMaterials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Tất cả vật tư đều đủ tồn kho!',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '${warningMaterials.length} vật tư cần nhập thêm hàng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: warningMaterials.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final m = warningMaterials[i];
                final pct = m.mucCanhBao > 0
                    ? (m.soLuongTon / m.mucCanhBao).clamp(0.0, 1.0)
                    : 0.0;
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0x1AEF4444),
                    child: Icon(Icons.warning, color: Colors.red),
                  ),
                  title: Text(
                    m.tenVatTu,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã: ${m.maVatTu}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct.toDouble(),
                        color: Colors.red,
                        backgroundColor: const Color(0x1AEF4444),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tồn: ${_fmt(m.soLuongTon)} ${m.donViTinh}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Cảnh báo: ${_fmt(m.mucCanhBao)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────
  Widget _tableCard({
    required List<String> headers,
    required List<int> flexes,
    required Color headerColor,
    required int count,
    required String label,
    required Widget Function(int) builder,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // header
          Container(
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: List.generate(
                headers.length,
                (i) => Expanded(
                  flex: flexes[i],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Text(
                      headers[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // rows
          Expanded(
            child: ListView.separated(
              itemCount: count,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => builder(i),
            ),
          ),
          // footer
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Tổng $count lần $label',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row({
    required bool isEven,
    required Color bgEven,
    required Color bgOdd,
    required List<Widget> cells,
  }) {
    return Container(
      color: isEven ? bgEven : bgOdd,
      child: Row(children: cells),
    );
  }

  Widget _cell(String text, int flex, {bool bold = false, Color? color}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _empty(IconData icon, String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
