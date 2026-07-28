/// Stub for Web - sqflite không hỗ trợ web
/// Toàn bộ dữ liệu được quản lý qua Firestore (FirestoreDataService)
/// nên không cần database local trên web.

import '../models/delivery_model.dart';
import '../models/export_model.dart';
import '../models/import_model.dart';
import '../models/material_model.dart';
import '../models/product_model.dart';
import '../models/supplier_model.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  // Trên web, database không được dùng.
  // Tất cả controllers dùng FirestoreDataService.

  //====================================================
  // MATERIAL
  //====================================================

  Future<int> addMaterial(MaterialModel material) async => 0;
  Future<List<MaterialModel>> getMaterials() async => [];
  Future<int> updateMaterial(MaterialModel material) async => 0;
  Future<int> deleteMaterial(int id) async => 0;
  Future<MaterialModel?> getMaterial(int id) async => null;

  //====================================================
  // PRODUCT
  //====================================================

  Future<int> addProduct(ProductModel product) async => 0;
  Future<List<ProductModel>> getProducts() async => [];
  Future<int> updateProduct(ProductModel product) async => 0;
  Future<int> deleteProduct(int id) async => 0;
  Future<ProductModel?> getProduct(int id) async => null;

  //====================================================
  // DELIVERY
  //====================================================

  Future<int> addDelivery(DeliveryModel delivery) async => 0;
  Future<List<DeliveryModel>> getDeliveries() async => [];
  Future<int> updateDelivery(DeliveryModel delivery) async => 0;
  Future<int> deleteDelivery(int id) async => 0;
  Future<DeliveryModel?> getDelivery(int id) async => null;
  Future<void> clearDeliveries() async {}

  //====================================================
  // SUPPLIER
  //====================================================

  Future<int> addSupplier(SupplierModel supplier) async => 0;
  Future<List<SupplierModel>> getSuppliers() async => [];
  Future<int> updateSupplier(SupplierModel supplier) async => 0;
  Future<int> deleteSupplier(int id) async => 0;

  //====================================================
  // IMPORT HISTORY
  //====================================================

  Future<int> addImportHistory(ImportModel record) async => 0;
  Future<List<ImportModel>> getImportHistory() async => [];
  Future<List<ImportModel>> getImportHistoryByMaterial(int materialId) async =>
      [];
  Future<int> deleteImportHistory(int id) async => 0;

  //====================================================
  // EXPORT HISTORY
  //====================================================

  Future<int> addExportHistory(ExportModel record) async => 0;
  Future<List<ExportModel>> getExportHistory() async => [];
  Future<List<ExportModel>> getExportHistoryByMaterial(int materialId) async =>
      [];
  Future<int> deleteExportHistory(int id) async => 0;

  //====================================================
  // CLOSE
  //====================================================

  Future<void> close() async {}
}
