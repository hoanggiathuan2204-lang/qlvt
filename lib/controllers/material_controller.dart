import '../models/export_model.dart';
import '../models/import_model.dart';
import '../models/material_model.dart';
import '../services/firestore_data_service.dart';

class MaterialController {
  //------------------------------------
  // Thêm vật tư
  //------------------------------------
  Future<void> addMaterial(MaterialModel material) async {
    await FirestoreDataService.addMaterial(material);
  }

  //------------------------------------
  // Cập nhật vật tư
  //------------------------------------
  Future<void> updateMaterial(MaterialModel material) async {
    await FirestoreDataService.updateMaterial(material);
  }

  //------------------------------------
  // Xóa vật tư
  //------------------------------------
  Future<void> deleteMaterial(MaterialModel material) async {
    await FirestoreDataService.deleteMaterial(material.id);
  }

  //------------------------------------
  // Danh sách vật tư
  //------------------------------------
  Future<List<MaterialModel>> getAll() async {
    return await FirestoreDataService.getMaterials();
  }

  //------------------------------------
  // Tìm kiếm
  //------------------------------------
  Future<List<MaterialModel>> search(String keyword) async {
    final list = await FirestoreDataService.getMaterials();
    if (keyword.trim().isEmpty) return list;
    final key = keyword.toLowerCase();
    return list.where((item) {
      return item.maVatTu.toLowerCase().contains(key) ||
          item.tenVatTu.toLowerCase().contains(key) ||
          item.nhomVatTu.toLowerCase().contains(key) ||
          item.nhaCungCap.toLowerCase().contains(key);
    }).toList();
  }

  //------------------------------------
  // Nhập kho (có lưu lịch sử)
  //------------------------------------
  Future<void> importMaterial(
    MaterialModel material,
    int quantity, {
    double donGia = 0,
    String nguoiNhap = '',
    String ghiChu = '',
  }) async {
    material.soLuongTon += quantity;
    await FirestoreDataService.updateMaterial(material);

    // Ghi lịch sử nhập kho
    FirestoreDataService.addNotification(
      action: 'import',
      description:
          'Nhập kho $quantity ${material.donViTinh} "${material.tenVatTu}"',
      targetType: 'material',
      targetId: material.id.toString(),
      targetName: material.tenVatTu,
    );
  }

  //------------------------------------
  // Xuất kho (có lưu lịch sử)
  //------------------------------------
  Future<bool> exportMaterial(
    MaterialModel material,
    int quantity, {
    String nguoiXuat = '',
    String lyDo = '',
    String ghiChu = '',
  }) async {
    if (material.soLuongTon < quantity) return false;

    material.soLuongTon -= quantity;
    await FirestoreDataService.updateMaterial(material);

    // Ghi lịch sử xuất kho
    FirestoreDataService.addNotification(
      action: 'export',
      description:
          'Xuất kho $quantity ${material.donViTinh} "${material.tenVatTu}"',
      targetType: 'material',
      targetId: material.id.toString(),
      targetName: material.tenVatTu,
    );

    return true;
  }

  //------------------------------------
  // Lịch sử nhập kho
  //------------------------------------
  Future<List<ImportModel>> getImportHistory() async {
    return const <ImportModel>[];
  }

  //------------------------------------
  // Lịch sử xuất kho
  //------------------------------------
  Future<List<ExportModel>> getExportHistory() async {
    return const <ExportModel>[];
  }

  //------------------------------------
  // Tổng vật tư
  //------------------------------------
  Future<int> totalMaterial() async {
    final list = await FirestoreDataService.getMaterials();
    return list.length;
  }

  //------------------------------------
  // Tổng tồn kho
  //------------------------------------
  Future<int> totalInventory() async {
    final list = await FirestoreDataService.getMaterials();
    return list.fold<int>(0, (sum, item) => sum + item.soLuongTon);
  }

  //------------------------------------
  // Số vật tư cảnh báo
  //------------------------------------
  Future<int> warningMaterial() async {
    final list = await FirestoreDataService.getMaterials();
    return list.where((item) => item.soLuongTon <= item.mucCanhBao).length;
  }

  //------------------------------------
  // Danh sách vật tư cảnh báo
  //------------------------------------
  Future<List<MaterialModel>> warningList() async {
    final list = await FirestoreDataService.getMaterials();
    return list.where((item) => item.soLuongTon <= item.mucCanhBao).toList();
  }
}
