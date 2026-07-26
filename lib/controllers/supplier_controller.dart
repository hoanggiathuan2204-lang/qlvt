import '../models/supplier_model.dart';
import '../services/firestore_data_service.dart';

class SupplierController {
  //------------------------------------
  // Lấy danh sách
  //------------------------------------
  Future<List<SupplierModel>> getAll() async {
    return await FirestoreDataService.getSuppliers();
  }

  //------------------------------------
  // Tìm kiếm
  //------------------------------------
  Future<List<SupplierModel>> search(String keyword) async {
    final list = await FirestoreDataService.getSuppliers();
    if (keyword.trim().isEmpty) return list;
    final key = keyword.toLowerCase();
    return list.where((s) {
      return s.maNCC.toLowerCase().contains(key) ||
          s.tenNCC.toLowerCase().contains(key) ||
          s.soDienThoai.toLowerCase().contains(key) ||
          s.nguoiLienHe.toLowerCase().contains(key);
    }).toList();
  }

  //------------------------------------
  // Thêm
  //------------------------------------
  Future<void> addSupplier(SupplierModel supplier) async {
    await FirestoreDataService.addSupplier(supplier);
  }

  //------------------------------------
  // Cập nhật
  //------------------------------------
  Future<void> updateSupplier(SupplierModel supplier) async {
    await FirestoreDataService.updateSupplier(supplier);
  }

  //------------------------------------
  // Xóa
  //------------------------------------
  Future<void> deleteSupplier(SupplierModel supplier) async {
    await FirestoreDataService.deleteSupplier(supplier.id);
  }

  //------------------------------------
  // Tổng nhà cung cấp
  //------------------------------------
  Future<int> total() async {
    final list = await FirestoreDataService.getSuppliers();
    return list.length;
  }

  //------------------------------------
  // Sinh mã NCC tự động
  //------------------------------------
  Future<String> generateCode() async {
    final list = await FirestoreDataService.getSuppliers();
    final n = list.length + 1;
    return 'NCC${n.toString().padLeft(3, '0')}';
  }
}
