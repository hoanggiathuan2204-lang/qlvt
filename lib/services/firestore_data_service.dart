import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/delivery_model.dart';
import '../models/material_model.dart';
import '../models/product_model.dart';
import '../models/supplier_model.dart';

class FirestoreDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get materialsRef =>
      _db.collection('materials');

  static CollectionReference<Map<String, dynamic>> get productsRef =>
      _db.collection('products');

  static CollectionReference<Map<String, dynamic>> get suppliersRef =>
      _db.collection('suppliers');

  static CollectionReference<Map<String, dynamic>> get deliveriesRef =>
      _db.collection('deliveries');

  static Future<List<MaterialModel>> getMaterials() async {
    if (kIsWeb) return _mockMaterials();
    final snapshot = await materialsRef.get();
    final list = <MaterialModel>[];
    for (final doc in snapshot.docs) {
      try {
        final data = _toPlainMap(doc.data());
        data['id'] = _safeInt(doc.id);
        list.add(MaterialModel.fromMap(data));
      } catch (_) {
        continue;
      }
    }
    list.sort((a, b) => a.tenVatTu.toLowerCase().compareTo(b.tenVatTu.toLowerCase()));
    return list;
  }

  static Future<void> addMaterial(MaterialModel material) async {
    if (kIsWeb) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await materialsRef.doc(id).set(material.toMap()..['id'] = int.parse(id));
  }

  static Future<void> updateMaterial(MaterialModel material) async {
    if (kIsWeb) return;
    if (material.id == 0) return;
    await materialsRef.doc(material.id.toString()).set(material.toMap());
  }

  static Future<void> deleteMaterial(int id) async {
    if (kIsWeb) return;
    await materialsRef.doc(id.toString()).delete();
  }

  static Future<List<ProductModel>> getProducts() async {
    if (kIsWeb) return _mockProducts();
    final snapshot = await productsRef.get();
    final list = <ProductModel>[];
    for (final doc in snapshot.docs) {
      try {
        final data = _toPlainMap(doc.data());
        data['id'] = _safeInt(doc.id);
        list.add(ProductModel.fromMap(data));
      } catch (_) {
        continue;
      }
    }
    list.sort((a, b) => a.tenSanPham.toLowerCase().compareTo(b.tenSanPham.toLowerCase()));
    return list;
  }

  static Future<void> addProduct(ProductModel product) async {
    if (kIsWeb) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await productsRef.doc(id).set(product.toMap()..['id'] = int.parse(id));
  }

  static Future<void> updateProduct(ProductModel product) async {
    if (kIsWeb) return;
    if (product.id == 0) return;
    await productsRef.doc(product.id.toString()).set(product.toMap());
  }

  static Future<void> deleteProduct(int id) async {
    if (kIsWeb) return;
    await productsRef.doc(id.toString()).delete();
  }

  static Future<List<SupplierModel>> getSuppliers() async {
    if (kIsWeb) return _mockSuppliers();
    final snapshot = await suppliersRef.get();
    final list = <SupplierModel>[];
    for (final doc in snapshot.docs) {
      try {
        final data = _toPlainMap(doc.data());
        data['id'] = _safeInt(doc.id);
        list.add(SupplierModel.fromMap(data));
      } catch (_) {
        continue;
      }
    }
    list.sort((a, b) => a.tenNCC.toLowerCase().compareTo(b.tenNCC.toLowerCase()));
    return list;
  }

  static Future<int> addSupplier(SupplierModel supplier) async {
    if (kIsWeb) return 1;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await suppliersRef.doc(id).set(supplier.toMap()..['id'] = int.parse(id));
    return int.parse(id);
  }

  static Future<void> updateSupplier(SupplierModel supplier) async {
    if (kIsWeb) return;
    if (supplier.id == 0) return;
    await suppliersRef.doc(supplier.id.toString()).set(supplier.toMap());
  }

  static Future<void> deleteSupplier(int id) async {
    if (kIsWeb) return;
    await suppliersRef.doc(id.toString()).delete();
  }

  static Future<List<DeliveryModel>> getDeliveries() async {
    if (kIsWeb) return _mockDeliveries();
    final snapshot = await deliveriesRef.get();
    final list = <DeliveryModel>[];
    for (final doc in snapshot.docs) {
      try {
        final data = _toPlainMap(doc.data());
        data['id'] = _safeInt(doc.id);
        list.add(DeliveryModel.fromMap(data));
      } catch (_) {
        continue;
      }
    }
    list.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
    return list;
  }

  static Future<int> addDelivery(DeliveryModel delivery) async {
    if (kIsWeb) return 1;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await deliveriesRef.doc(id).set(delivery.toMap()..['id'] = int.parse(id));
    return int.parse(id);
  }

  static Future<void> updateDelivery(DeliveryModel delivery) async {
    if (kIsWeb) return;
    await deliveriesRef.doc(delivery.id.toString()).set(delivery.toMap());
  }

  static Future<void> deleteDelivery(int id) async {
    if (kIsWeb) return;
    await deliveriesRef.doc(id.toString()).delete();
  }

  static Future<void> clearDeliveries() async {
    if (kIsWeb) return;
    final snapshot = await deliveriesRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Map<String, dynamic> _toPlainMap(Map<dynamic, dynamic>? raw) {
    if (raw == null) return <String, dynamic>{};
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final entry in raw.entries) {
      final String k = entry.key.toString();
      final dynamic value = entry.value;
      if (value == null) {
        result[k] = null;
        continue;
      }
      if (value is String || value is int || value is double || value is bool) {
        result[k] = value;
        continue;
      }
      try {
        final dt = (value as dynamic).toDate();
        if (dt is DateTime) {
          result[k] = dt.toIso8601String();
          continue;
        }
      } catch (_) {}
      if (value is Map) {
        result[k] = _toPlainMap(value);
      } else if (value is List) {
        result[k] = value.map((e) => _toPlainMap(e is Map ? e : <dynamic, dynamic>{})).toList();
      } else {
        result[k] = value.toString();
      }
    }
    return result;
  }

  static int _safeInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch;
    return DateTime.now().millisecondsSinceEpoch;
  }

  static List<MaterialModel> _mockMaterials() => [
    MaterialModel(
      id: 1,
      maVatTu: 'VT001',
      tenVatTu: 'Xi măng PCB40',
      nhomVatTu: 'Vật liệu xây dựng',
      donViTinh: 'bao',
      soLuongTon: 500,
      mucCanhBao: 100,
      giaNhap: 85000,
      nhaCungCap: 'NCC001',
    ),
    MaterialModel(
      id: 2,
      maVatTu: 'VT002',
      tenVatTu: 'Thép phi 10',
      nhomVatTu: 'Vật liệu xây dựng',
      donViTinh: 'cây',
      soLuongTon: 200,
      mucCanhBao: 50,
      giaNhap: 120000,
      nhaCungCap: 'NCC002',
    ),
    MaterialModel(
      id: 3,
      maVatTu: 'VT003',
      tenVatTu: 'Cát xây',
      nhomVatTu: 'Vật liệu xây dựng',
      donViTinh: 'm3',
      soLuongTon: 30,
      mucCanhBao: 10,
      giaNhap: 250000,
      nhaCungCap: 'NCC001',
    ),
  ];

  static List<ProductModel> _mockProducts() => [
    ProductModel(
      id: 1,
      maSanPham: 'SP001',
      tenSanPham: 'Cột bê tông cốt thép',
      donVi: 'cột',
      soKien: 120,
      diaChiLapRap: 'Tại công trình',
      ngayTao: DateTime.now(),
    ),
    ProductModel(
      id: 2,
      maSanPham: 'SP002',
      tenSanPham: 'Dầm bê tông cốt thép',
      donVi: 'dầm',
      soKien: 80,
      diaChiLapRap: 'Tại công trình',
      ngayTao: DateTime.now(),
    ),
  ];

  static List<SupplierModel> _mockSuppliers() => [
    SupplierModel(
      id: 1,
      maNCC: 'NCC001',
      tenNCC: 'Công ty TNHH Vật liệu Xây dựng A',
      diaChi: 'Hà Nội',
      soDienThoai: '0909123456',
      email: 'ncc001@gmail.com',
      nguoiLienHe: 'Nguyễn Văn A',
      ghiChu: '',
      ngayTao: DateTime.now(),
    ),
    SupplierModel(
      id: 2,
      maNCC: 'NCC002',
      tenNCC: 'Công ty Thép B',
      diaChi: 'TP.HCM',
      soDienThoai: '0909789456',
      email: 'ncc002@gmail.com',
      nguoiLienHe: 'Trần Thị B',
      ghiChu: '',
      ngayTao: DateTime.now(),
    ),
  ];

  static List<DeliveryModel> _mockDeliveries() => [
    DeliveryModel(
      id: 1,
      tenSanPham: 'Cột bê tông cốt thép',
      soKien: 20,
      diaChiGiao: 'Công trình A',
      nguoiBocHang: 'Người bốc 1',
      taiXe: 'Nguyễn Văn Tài',
      bienSoXe: '29A-12345',
      thoiGian: DateTime.now().subtract(const Duration(days: 1)),
      ghiChu: '',
    ),
    DeliveryModel(
      id: 2,
      tenSanPham: 'Dầm bê tông cốt thép',
      soKien: 15,
      diaChiGiao: 'Công trình B',
      nguoiBocHang: 'Người bốc 2',
      taiXe: 'Trần Văn Tài',
      bienSoXe: '30B-67890',
      thoiGian: DateTime.now().subtract(const Duration(days: 2)),
      ghiChu: '',
    ),
  ];
}
