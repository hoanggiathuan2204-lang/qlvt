import '../models/product_model.dart';
import '../services/firestore_data_service.dart';

class ProductController {
  //------------------------------------
  // Lấy danh sách
  //------------------------------------
  Future<List<ProductModel>> getProducts() async {
    return await FirestoreDataService.getProducts();
  }

  //------------------------------------
  // Tìm kiếm
  //------------------------------------
  Future<List<ProductModel>> search(String keyword) async {
    final list = await FirestoreDataService.getProducts();
    if (keyword.trim().isEmpty) return list;
    final key = keyword.toLowerCase();
    return list.where((p) {
      return p.maSanPham.toLowerCase().contains(key) ||
          p.tenSanPham.toLowerCase().contains(key) ||
          p.diaChiLapRap.toLowerCase().contains(key);
    }).toList();
  }

  //------------------------------------
  // Thêm
  //------------------------------------
  Future<void> addProduct(ProductModel product) async {
    await FirestoreDataService.addProduct(product);
  }

  //------------------------------------
  // Cập nhật
  //------------------------------------
  Future<void> updateProduct(ProductModel product) async {
    await FirestoreDataService.updateProduct(product);
  }

  //------------------------------------
  // Xóa
  //------------------------------------
  Future<void> deleteProduct(ProductModel product) async {
    await FirestoreDataService.deleteProduct(product.id);
  }

  //------------------------------------
  // Nhập kho thành phẩm
  //------------------------------------
  Future<void> importProduct(ProductModel product, int quantity) async {
    product.soKien += quantity;
    await FirestoreDataService.updateProduct(product);
    FirestoreDataService.addNotification(
      action: 'import',
      description: 'Nhập kho $quantity "${product.tenSanPham}"',
      targetType: 'product',
      targetId: product.id.toString(),
      targetName: product.tenSanPham,
    );
  }

  //------------------------------------
  // Xuất kho thành phẩm
  //------------------------------------
  Future<bool> exportProduct(ProductModel product, int quantity) async {
    if (product.soKien < quantity) return false;
    product.soKien -= quantity;
    await FirestoreDataService.updateProduct(product);
    FirestoreDataService.addNotification(
      action: 'export',
      description: 'Xuất kho $quantity "${product.tenSanPham}"',
      targetType: 'product',
      targetId: product.id.toString(),
      targetName: product.tenSanPham,
    );
    return true;
  }

  //------------------------------------
  // Tổng số loại thành phẩm
  //------------------------------------
  Future<int> totalProduct() async {
    final list = await FirestoreDataService.getProducts();
    return list.length;
  }

  //------------------------------------
  // Tổng số kiện (giữ tên gốc totalPackage để không vỡ code cũ)
  //------------------------------------
  Future<int> totalPackage() async {
    final list = await FirestoreDataService.getProducts();
    return list.fold<int>(0, (sum, p) => sum + p.soKien);
  }

  // Alias khác tên
  Future<int> totalKien() => totalPackage();
}
