import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/material_model.dart';
import '../theme/app_colors.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/export_dialog.dart';
import '../widgets/import_dialog.dart';
import '../widgets/material_card.dart';
import '../widgets/material_dialog.dart';

class MaterialScreen extends StatefulWidget {
  final bool showSidebar;
  const MaterialScreen({super.key, this.showSidebar = true});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final controller = AppData.materialController;
  final TextEditingController searchController = TextEditingController();
  List<MaterialModel> materials = [];
  int selectedMenu = 1;

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
      setState(() => materials = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải vật tư: $e'), backgroundColor: Colors.red),
      );
    }
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
          SnackBar(content: Text('Lỗi thêm vật tư: $e'), backgroundColor: Colors.red),
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
      await controller.deleteMaterial(material);
      await refreshList();
      _showSnack('Đã xóa vật tư', Colors.red);
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
        (result['soLuong'] as num?)?.toInt() ?? 0,
        donGia: (result['donGia'] as num?)?.toDouble() ?? 0.0,
        nguoiNhap: result['nguoiNhap']?.toString() ?? '',
        ghiChu: result['ghiChu']?.toString() ?? '',
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
        (result['soLuong'] as num?)?.toInt() ?? 0,
        nguoiXuat: result['nguoiXuat']?.toString() ?? '',
        lyDo: result['lyDo']?.toString() ?? '',
        ghiChu: result['ghiChu']?.toString() ?? '',
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
    final Widget content = Column(
      children: [
        DashboardHeader(title: 'Quản lý vật tư', userName: 'Administrator'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Tìm kiếm
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (_) => refreshList(),
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
}
