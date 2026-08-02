import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/material_model.dart';
import '../services/firestore_data_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/export_dialog.dart';
import '../widgets/import_dialog.dart';
import '../widgets/material_card.dart';
import '../widgets/material_dialog.dart';

class MaterialScreen extends StatefulWidget {
  final bool showSidebar;
  final VoidCallback? onMenuTap;
  const MaterialScreen({super.key, this.showSidebar = true, this.onMenuTap});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final controller = AppData.materialController;
  final TextEditingController searchController = TextEditingController();
  final Stream<List<MaterialModel>> _materialsStream =
      FirestoreDataService.streamMaterials();
  StreamSubscription<List<MaterialModel>>? _materialsSub;
  List<MaterialModel> _allMaterials = [];
  List<MaterialModel> materials = [];
  String _searchQuery = '';
  int selectedMenu = 1;

  @override
  void initState() {
    super.initState();
    _materialsSub = _materialsStream.listen(
      (list) {
        if (!mounted) return;
        setState(() {
          _allMaterials = list;
          materials = _filterMaterials(_allMaterials, _searchQuery);
        });
      },
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải vật tư: $e'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _materialsSub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  List<MaterialModel> _filterMaterials(List<MaterialModel> list, String query) {
    if (query.trim().isEmpty) return list;
    final key = query.toLowerCase();
    return list.where((item) {
      return item.maVatTu.toLowerCase().contains(key) ||
          item.tenVatTu.toLowerCase().contains(key) ||
          item.nhomVatTu.toLowerCase().contains(key) ||
          item.nhaCungCap.toLowerCase().contains(key);
    }).toList();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    setState(() {
      materials = _filterMaterials(_allMaterials, _searchQuery);
    });
  }

  Future<void> refreshList() async {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> addMaterial() async {
    final result = await showDialog<MaterialModel>(
      context: context,
      builder: (_) => const MaterialDialog(),
    );
    if (result != null) {
      try {
        await controller.addMaterial(result);
        await refreshList();
        _showSnack('Đã thêm vật tư thành công', Colors.green);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thêm vật tư: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> editMaterial(MaterialModel material) async {
    final result = await showDialog<MaterialModel>(
      context: context,
      builder: (_) => MaterialDialog(material: material),
    );
    if (result != null) {
      await controller.updateMaterial(result);
      await refreshList();
      _showSnack('Đã cập nhật vật tư', Colors.blue);
    }
  }

  Future<void> deleteMaterial(MaterialModel material) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa vật tư "${material.tenVatTu}"?'),
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
      try {
        await controller.deleteMaterial(material);
        if (!mounted) return;
        setState(() {
          _allMaterials.removeWhere((item) => item.id == material.id);
          materials = _filterMaterials(_allMaterials, _searchQuery);
        });
        _showSnack('Đã xóa vật tư', Colors.red);
      } catch (e) {
        if (!mounted) return;
        _showSnack('Lỗi xóa vật tư: $e', Colors.red);
      }
    }
  }

  Future<void> importMaterial(MaterialModel material) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ImportDialog(material: material),
    );
    if (result != null) {
      await controller.importMaterial(
        material,
        result['soLuong'] as int,
        donGia: result['donGia'] as double,
        nguoiNhap: result['nguoiNhap'] as String,
        ghiChu: result['ghiChu'] as String,
      );
      await refreshList();
      _showSnack(
        'Đã nhập kho ${result['soLuong']} ${material.donViTinh}',
        Colors.blue,
      );
    }
  }

  Future<void> exportMaterial(MaterialModel material) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ExportDialog(material: material),
    );
    if (result != null) {
      final ok = await controller.exportMaterial(
        material,
        result['soLuong'] as int,
        nguoiXuat: result['nguoiXuat'] as String,
        lyDo: result['lyDo'] as String,
        ghiChu: result['ghiChu'] as String,
      );
      if (ok) {
        await refreshList();
        _showSnack(
          'Đã xuất kho ${result['soLuong']} ${material.donViTinh}',
          Colors.orange,
        );
      } else {
        _showSnack('Không đủ tồn kho để xuất!', Colors.red);
      }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final Widget content = Column(
      children: [
        DashboardHeader(
          title: 'Quản lý vật tư',
          userName: 'Administrator',
          onMenuTap: widget.onMenuTap,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            child: Column(
              children: [
                //------------------------------------
                // Toolbar
                //------------------------------------
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 16,
                      vertical: isMobile ? 8 : 12,
                    ),
                    child: isMobile
                        ? Column(
                            children: [
                              // Tìm kiếm - full width on mobile
                              TextField(
                                controller: searchController,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: addMaterial,
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Thêm'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: refreshList,
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('Làm mới'),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              // Tìm kiếm
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: _onSearchChanged,
                                  decoration: InputDecoration(
                                    hintText: 'Tìm theo mã, tên, nhóm, NCC...',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: addMaterial,
                                icon: const Icon(Icons.add),
                                label: const Text('Thêm vật tư'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: refreshList,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Làm mới'),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                //------------------------------------
                // Danh sách vật tư
                //------------------------------------
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    child: materials.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 180),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 80,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      'Không có vật tư',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: materials.length,
                            itemBuilder: (_, index) {
                              final item = materials[index];
                              return MaterialCard(
                                material: item,
                                onEdit: () => editMaterial(item),
                                onDelete: () => deleteMaterial(item),
                                onImport: () => importMaterial(item),
                                onExport: () => exportMaterial(item),
                              );
                            },
                          ),
                  ),
                ),
                // Tổng số
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Tổng: ${materials.length} vật tư',
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
}
