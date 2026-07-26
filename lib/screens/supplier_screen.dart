import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/supplier_model.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/supplier_dialog.dart';

class SupplierScreen extends StatefulWidget {
  final bool showSidebar;
  const SupplierScreen({super.key, this.showSidebar = true});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  final controller = AppData.supplierController;
  final searchController = TextEditingController();
  List<SupplierModel> suppliers = [];
  int selectedMenu = 2; // Nhà cung cấp là menu index 2

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

  Future<void> refreshList() async {
    try {
      final result = await controller.search(searchController.text);
      if (!mounted) return;
      setState(() => suppliers = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải nhà cung cấp: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> addSupplier() async {
    final code = await controller.generateCode();
    if (!mounted) return;
    final result = await showDialog<SupplierModel>(
      context: context,
      builder: (_) => SupplierDialog(initialCode: code),
    );
    if (result != null) {
      await controller.addSupplier(result);
      await refreshList();
      _showSnack('Đã thêm nhà cung cấp thành công', Colors.green);
    }
  }

  Future<void> editSupplier(SupplierModel supplier) async {
    final result = await showDialog<SupplierModel>(
      context: context,
      builder: (_) => SupplierDialog(supplier: supplier),
    );
    if (result != null) {
      await controller.updateSupplier(result);
      await refreshList();
      _showSnack('Đã cập nhật nhà cung cấp', Colors.blue);
    }
  }

  Future<void> deleteSupplier(SupplierModel supplier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${supplier.tenNCC}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await controller.deleteSupplier(supplier);
      await refreshList();
      _showSnack('Đã xóa nhà cung cấp', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      children: [
        DashboardHeader(title: 'Nhà cung cấp', userName: 'Administrator'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //-----------------------------
                // Tiêu đề + nút thêm
                //-----------------------------
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      color: Color(0xff0D4F8B),
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Danh sách nhà cung cấp',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: addSupplier,
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm NCC'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                //-----------------------------
                // Tìm kiếm
                //-----------------------------
                TextField(
                  controller: searchController,
                  onChanged: (_) => refreshList(),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo mã, tên, SĐT...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //-----------------------------
                // Bảng danh sách
                //-----------------------------
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: suppliers.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.business_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Chưa có nhà cung cấp nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Header bảng
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xff0D4F8B),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    _TH('Mã NCC', flex: 1),
                                    _TH('Tên nhà cung cấp', flex: 2),
                                    _TH('Số điện thoại', flex: 1),
                                    _TH('Email', flex: 2),
                                    _TH('Người liên hệ', flex: 1),
                                    _TH('Thao tác', flex: 1),
                                  ],
                                ),
                              ),
                              // Rows
                              Expanded(
                                child: ListView.separated(
                                  itemCount: suppliers.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (_, i) {
                                    final s = suppliers[i];
                                    return _SupplierRow(
                                      supplier: s,
                                      onEdit: () => editSupplier(s),
                                      onDelete: () => deleteSupplier(s),
                                      isEven: i % 2 == 0,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                // Tổng số
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tổng: ${suppliers.length} nhà cung cấp',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.showSidebar) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            DashboardSidebar(
              selectedIndex: selectedMenu,
              onSelect: (value) => setState(() => selectedMenu = value),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(backgroundColor: AppColors.background, body: content);
  }
}

//----------------------------------------------------
// Widget header cột bảng
//----------------------------------------------------
class _TH extends StatelessWidget {
  final String text;
  final int flex;
  const _TH(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

//----------------------------------------------------
// Widget một hàng trong bảng
//----------------------------------------------------
class _SupplierRow extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isEven;

  const _SupplierRow({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.white : const Color(0xffF8FAFD),
      child: Row(
        children: [
          _TD(
            supplier.maNCC,
            flex: 1,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xff0D4F8B),
            ),
          ),
          _TD(supplier.tenNCC, flex: 2),
          _TD(
            supplier.soDienThoai.isEmpty ? '—' : supplier.soDienThoai,
            flex: 1,
          ),
          _TD(supplier.email.isEmpty ? '—' : supplier.email, flex: 2),
          _TD(
            supplier.nguoiLienHe.isEmpty ? '—' : supplier.nguoiLienHe,
            flex: 1,
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Chỉnh sửa',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  ),
                  IconButton(
                    tooltip: 'Xóa',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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

class _TD extends StatelessWidget {
  final String text;
  final int flex;
  final TextStyle? style;
  const _TD(this.text, {required this.flex, this.style});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          text,
          style: style ?? const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
