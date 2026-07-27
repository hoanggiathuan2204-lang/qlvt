import 'package:cloud_firestore/cloud_firestore.dart';

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
    try {
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
    } catch (_) {
      return <MaterialModel>[];
    }
  }

  static Future<void> addMaterial(MaterialModel material) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await materialsRef.doc(id).set(material.toMap()..['id'] = int.parse(id));
  }

  static Future<void> updateMaterial(MaterialModel material) async {
    if (material.id == 0) return;
    await materialsRef.doc(material.id.toString()).set(material.toMap());
  }

  static Future<void> deleteMaterial(int id) async {
    await materialsRef.doc(id.toString()).delete();
  }

  static Future<List<ProductModel>> getProducts() async {
    try {
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
    } catch (_) {
      return <ProductModel>[];
    }
  }

  static Future<void> addProduct(ProductModel product) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await productsRef.doc(id).set(product.toMap()..['id'] = int.parse(id));
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
    } catch (_) {
      return <SupplierModel>[];
    }
  }

  static Future<int> addSupplier(SupplierModel supplier) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await suppliersRef.doc(id).set(supplier.toMap()..['id'] = int.parse(id));
    return int.parse(id);
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
    } catch (_) {
      return <DeliveryModel>[];
    }
  }

  static Future<int> addDelivery(DeliveryModel delivery) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await deliveriesRef.doc(id).set(delivery.toMap()..['id'] = int.parse(id));
    return int.parse(id);
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
}
