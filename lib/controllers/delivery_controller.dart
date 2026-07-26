import '../models/delivery_model.dart';
import '../services/firestore_data_service.dart';

class DeliveryController {
  final List<DeliveryModel> _deliveries = [];
  bool _loaded = false;

  //==================================================
  // Load toàn bộ từ DB
  //==================================================

  Future<void> load() async {
    if (!_loaded) {
      _deliveries.clear();
      _deliveries.addAll(await FirestoreDataService.getDeliveries());
      _loaded = true;
    }
  }

  //==================================================
  // Thêm phiếu giao hàng
  // Giữ cả 2 tên: add() và addDelivery() để tương thích
  //==================================================

  Future<void> addDelivery(DeliveryModel delivery) async {
    final id = await FirestoreDataService.addDelivery(delivery);
    final saved = delivery.copyWith(id: id);
    _deliveries.insert(0, saved);
    _loaded = true;
  }

  Future<void> add(DeliveryModel delivery) => addDelivery(delivery);

  //==================================================
  // Cập nhật
  //==================================================

  Future<void> updateDelivery(DeliveryModel delivery) async {
    await FirestoreDataService.updateDelivery(delivery);
    final idx = _deliveries.indexWhere((d) => d.id == delivery.id);
    if (idx >= 0) _deliveries[idx] = delivery;
  }

  Future<void> update(DeliveryModel delivery) => updateDelivery(delivery);

  //==================================================
  // Xóa
  //==================================================

  Future<void> deleteDelivery(DeliveryModel delivery) async {
    await FirestoreDataService.deleteDelivery(delivery.id);
    _deliveries.removeWhere((d) => d.id == delivery.id);
  }

  Future<void> delete(DeliveryModel delivery) => deleteDelivery(delivery);

  //==================================================
  // Danh sách toàn bộ
  //==================================================

  Future<List<DeliveryModel>> getAll() async {
    await load();
    return List<DeliveryModel>.from(_deliveries);
  }

  //==================================================
  // Tìm kiếm
  //==================================================

  Future<List<DeliveryModel>> search(String keyword) async {
    await load();
    if (keyword.trim().isEmpty) return List<DeliveryModel>.from(_deliveries);
    final key = keyword.toLowerCase();
    return _deliveries.where((item) {
      return item.tenSanPham.toLowerCase().contains(key) ||
          item.taiXe.toLowerCase().contains(key) ||
          item.bienSoXe.toLowerCase().contains(key) ||
          item.diaChiGiao.toLowerCase().contains(key);
    }).toList();
  }

  //==================================================
  // Danh sách mới nhất
  //==================================================

  Future<List<DeliveryModel>> newest() async {
    await load();
    final list = List<DeliveryModel>.from(_deliveries);
    list.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
    return list;
  }

  //==================================================
  // Tổng số phiếu giao
  //==================================================

  Future<int> totalDelivery() async {
    await load();
    return _deliveries.length;
  }

  //==================================================
  // Refresh (buộc load lại từ DB)
  //==================================================

  Future<void> refresh() async {
    _loaded = false;
    await load();
  }

  //==================================================
  // Xóa toàn bộ
  //==================================================

  Future<void> clearAll() async {
    await FirestoreDataService.clearDeliveries();
    _deliveries.clear();
    _loaded = true;
  }
}
