import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static String? _currentUserId() => FirebaseAuth.instance.currentUser?.uid;

  static Query<Map<String, dynamic>> _withUserFilter(
    Query<Map<String, dynamic>> query,
  ) {
    final uid = _currentUserId();
    if (uid == null) return query;
    return query.where('userId', isEqualTo: uid);
  }

  static Future<List<MaterialModel>> getMaterials() async {
    try {
      final uid = _currentUserId();
      print('[FS] getMaterials uid=$uid');
      final query = uid == null
          ? materialsRef
          : materialsRef.where('userId', isEqualTo: uid);
      final snapshot = await query.get();
      print('[FS] getMaterials snapshot.size=${snapshot.size}');
      final list = <MaterialModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(MaterialModel.fromMap(data));
        } catch (e) {
          print('[FS] getMaterials skip doc=${doc.id} err=$e');
          continue;
        }
      }
      list.sort(
        (a, b) => a.tenVatTu.toLowerCase().compareTo(b.tenVatTu.toLowerCase()),
      );
      print('[FS] getMaterials result=${list.length}');
      return list;
    } catch (e) {
      print('[FS] getMaterials FAILED: $e');
      return <MaterialModel>[];
    }
  }

  static Future<void> addMaterial(MaterialModel material) async {
    try {
      final uid = _currentUserId();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = material.toMap()..['id'] = int.parse(id);
      if (uid != null) data['userId'] = uid;
      print('[FS] addMaterial doc=$id uid=$uid dataKeys=${data.keys.toList()}');
      await materialsRef.doc(id).set(data);
      print('[FS] addMaterial DONE doc=$id');
    } catch (e) {
      print('[FS] addMaterial FAILED: $e');
      throw Exception('Không thể thêm vật tư: $e');
    }
  }

  static Future<void> updateMaterial(MaterialModel material) async {
    if (material.id == 0) return;
    final data = material.toMap();
    await materialsRef.doc(material.id.toString()).set(data);
  }

  static Future<void> deleteMaterial(int id) async {
    await materialsRef.doc(id.toString()).delete();
  }

  static Future<List<ProductModel>> getProducts() async {
    try {
      final uid = _currentUserId();
      print('[FS] getProducts uid=$uid');
      final query = uid == null
          ? productsRef
          : productsRef.where('userId', isEqualTo: uid);
      final snapshot = await query.get();
      print('[FS] getProducts snapshot.size=${snapshot.size}');
      final list = <ProductModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(ProductModel.fromMap(data));
        } catch (e) {
          print('[FS] getProducts skip doc=${doc.id} err=$e');
          continue;
        }
      }
      list.sort(
        (a, b) =>
            a.tenSanPham.toLowerCase().compareTo(b.tenSanPham.toLowerCase()),
      );
      print('[FS] getProducts result=${list.length}');
      return list;
    } catch (e) {
      print('[FS] getProducts FAILED: $e');
      return <ProductModel>[];
    }
  }

  static Future<void> addProduct(ProductModel product) async {
    try {
      final uid = _currentUserId();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = product.toMap()..['id'] = int.parse(id);
      if (uid != null) data['userId'] = uid;
      print('[FS] addProduct doc=$id uid=$uid');
      await productsRef.doc(id).set(data);
      print('[FS] addProduct DONE doc=$id');
    } catch (e) {
      print('[FS] addProduct FAILED: $e');
      throw Exception('Không thể thêm thành phẩm: $e');
    }
  }

  static Future<void> updateProduct(ProductModel product) async {
    if (product.id == 0) return;
    await productsRef.doc(product.id.toString()).set(product.toMap());
  }

  static Future<void> deleteProduct(int id) async {
    await productsRef.doc(id.toString()).delete();
  }

  static Future<List<SupplierModel>> getSuppliers() async {
    try {
      final uid = _currentUserId();
      print('[FS] getSuppliers uid=$uid');
      final query = uid == null
          ? suppliersRef
          : suppliersRef.where('userId', isEqualTo: uid);
      final snapshot = await query.get();
      print('[FS] getSuppliers snapshot.size=${snapshot.size}');
      final list = <SupplierModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(SupplierModel.fromMap(data));
        } catch (e) {
          print('[FS] getSuppliers skip doc=${doc.id} err=$e');
          continue;
        }
      }
      list.sort(
        (a, b) => a.tenNCC.toLowerCase().compareTo(b.tenNCC.toLowerCase()),
      );
      print('[FS] getSuppliers result=${list.length}');
      return list;
    } catch (e) {
      print('[FS] getSuppliers FAILED: $e');
      return <SupplierModel>[];
    }
  }

  static Future<int> addSupplier(SupplierModel supplier) async {
    try {
      final uid = _currentUserId();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = supplier.toMap()..['id'] = int.parse(id);
      if (uid != null) data['userId'] = uid;
      print('[FS] addSupplier doc=$id uid=$uid');
      await suppliersRef.doc(id).set(data);
      print('[FS] addSupplier DONE doc=$id');
      return int.parse(id);
    } catch (e) {
      print('[FS] addSupplier FAILED: $e');
      throw Exception('Không thể thêm nhà cung cấp: $e');
    }
  }

  static Future<void> updateSupplier(SupplierModel supplier) async {
    if (supplier.id == 0) return;
    await suppliersRef.doc(supplier.id.toString()).set(supplier.toMap());
  }

  static Future<void> deleteSupplier(int id) async {
    await suppliersRef.doc(id.toString()).delete();
  }

  static Future<List<DeliveryModel>> getDeliveries() async {
    try {
      final uid = _currentUserId();
      print('[FS] getDeliveries uid=$uid');
      final query = uid == null
          ? deliveriesRef
          : deliveriesRef.where('userId', isEqualTo: uid);
      final snapshot = await query.get();
      print('[FS] getDeliveries snapshot.size=${snapshot.size}');
      final list = <DeliveryModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(DeliveryModel.fromMap(data));
        } catch (e) {
          print('[FS] getDeliveries skip doc=${doc.id} err=$e');
          continue;
        }
      }
      list.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
      print('[FS] getDeliveries result=${list.length}');
      return list;
    } catch (e) {
      print('[FS] getDeliveries FAILED: $e');
      return <DeliveryModel>[];
    }
  }

  static Future<int> addDelivery(DeliveryModel delivery) async {
    try {
      final uid = _currentUserId();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = delivery.toMap()..['id'] = int.parse(id);
      if (uid != null) data['userId'] = uid;
      print('[FS] addDelivery doc=$id uid=$uid');
      await deliveriesRef.doc(id).set(data);
      print('[FS] addDelivery DONE doc=$id');
      return int.parse(id);
    } catch (e) {
      print('[FS] addDelivery FAILED: $e');
      throw Exception('Không thể thêm phiếu giao: $e');
    }
  }

  static Future<void> updateDelivery(DeliveryModel delivery) async {
    await deliveriesRef.doc(delivery.id.toString()).set(delivery.toMap());
  }

  static Future<void> deleteDelivery(int id) async {
    await deliveriesRef.doc(id.toString()).delete();
  }

  static Future<void> clearDeliveries() async {
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
      if (value is Timestamp) {
        result[k] = value.toDate().toIso8601String();
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
        result[k] = value
            .map((e) => _toPlainMap(e is Map ? e : <dynamic, dynamic>{}))
            .toList();
      } else {
        result[k] = value.toString();
      }
    }
    return result;
  }

  static int _safeInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String)
      return int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch;
    return DateTime.now().millisecondsSinceEpoch;
  }
}
