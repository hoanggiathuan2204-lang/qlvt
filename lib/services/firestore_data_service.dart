import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/delivery_model.dart';
import '../models/material_model.dart';
import '../models/product_model.dart';
import '../models/supplier_model.dart';

class FirestoreDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const _projectId = 'qlvt-4d1fc';

  static CollectionReference<Map<String, dynamic>> get materialsRef =>
      _db.collection('materials');

  static CollectionReference<Map<String, dynamic>> get productsRef =>
      _db.collection('products');

  static CollectionReference<Map<String, dynamic>> get suppliersRef =>
      _db.collection('suppliers');

  static CollectionReference<Map<String, dynamic>> get deliveriesRef =>
      _db.collection('deliveries');

  static Future<String?> _getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  static Future<Map<String, dynamic>> _restGet(String path) async {
    if (!kIsWeb) {
      throw UnsupportedError('REST API is only for web');
    }
    final token = await _getIdToken();
    if (token == null) {
      throw Exception('Chưa đăng nhập');
    }
    final uri = Uri.parse('https://firestore.googleapis.com/v1/$path');
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.add('Authorization', 'Bearer $token');
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final body = await response.transform(utf8.decoder).join();
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  static Future<List<MaterialModel>> getMaterials() async {
    if (kIsWeb) {
      final data = await _restGet('projects/$_projectId/databases/(default)/documents/materials');
      final docs = (data['documents'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
      final list = <MaterialModel>[];
      for (final doc in docs) {
        try {
          final fields = doc['fields'] as Map<String, dynamic>;
          final map = <String, dynamic>{};
          for (final entry in fields.entries) {
            map[entry.key] = _restValue(entry.value);
          }
          map['id'] = int.tryParse(doc['name'].split('/').last) ?? DateTime.now().millisecondsSinceEpoch;
          list.add(MaterialModel.fromMap(map));
        } catch (_) {
          continue;
        }
      }
      list.sort((a, b) => a.tenVatTu.toLowerCase().compareTo(b.tenVatTu.toLowerCase()));
      return list;
    }
    final snapshot = await materialsRef.orderBy('tenVatTu').get();
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
    if (kIsWeb) {
      final data = await _restGet('projects/$_projectId/databases/(default)/documents/products');
      final docs = (data['documents'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
      final list = <ProductModel>[];
      for (final doc in docs) {
        try {
          final fields = doc['fields'] as Map<String, dynamic>;
          final map = <String, dynamic>{};
          for (final entry in fields.entries) {
            map[entry.key] = _restValue(entry.value);
          }
          map['id'] = int.tryParse(doc['name'].split('/').last) ?? DateTime.now().millisecondsSinceEpoch;
          list.add(ProductModel.fromMap(map));
        } catch (_) {
          continue;
        }
      }
      list.sort((a, b) => a.tenSanPham.toLowerCase().compareTo(b.tenSanPham.toLowerCase()));
      return list;
    }
    final snapshot = await productsRef.orderBy('tenSanPham').get();
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
    if (kIsWeb) {
      final data = await _restGet('projects/$_projectId/databases/(default)/documents/suppliers');
      final docs = (data['documents'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
      final list = <SupplierModel>[];
      for (final doc in docs) {
        try {
          final fields = doc['fields'] as Map<String, dynamic>;
          final map = <String, dynamic>{};
          for (final entry in fields.entries) {
            map[entry.key] = _restValue(entry.value);
          }
          map['id'] = int.tryParse(doc['name'].split('/').last) ?? DateTime.now().millisecondsSinceEpoch;
          list.add(SupplierModel.fromMap(map));
        } catch (_) {
          continue;
        }
      }
      list.sort((a, b) => a.tenNCC.toLowerCase().compareTo(b.tenNCC.toLowerCase()));
      return list;
    }
    final snapshot = await suppliersRef.orderBy('tenNCC').get();
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
    if (kIsWeb) {
      final data = await _restGet('projects/$_projectId/databases/(default)/documents/deliveries');
      final docs = (data['documents'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
      final list = <DeliveryModel>[];
      for (final doc in docs) {
        try {
          final fields = doc['fields'] as Map<String, dynamic>;
          final map = <String, dynamic>{};
          for (final entry in fields.entries) {
            map[entry.key] = _restValue(entry.value);
          }
          map['id'] = int.tryParse(doc['name'].split('/').last) ?? DateTime.now().millisecondsSinceEpoch;
          list.add(DeliveryModel.fromMap(map));
        } catch (_) {
          continue;
        }
      }
      list.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
      return list;
    }
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

  static dynamic _restValue(Map<String, dynamic> value) {
    if (value.containsKey('stringValue')) return value['stringValue'] as String;
    if (value.containsKey('integerValue')) return int.parse(value['integerValue'] as String);
    if (value.containsKey('doubleValue')) return double.parse(value['doubleValue'] as String);
    if (value.containsKey('booleanValue')) return value['booleanValue'] as bool;
    if (value.containsKey('timestampValue')) return value['timestampValue'] as String;
    if (value.containsKey('nullValue')) return null;
    if (value.containsKey('arrayValue')) {
      final arr = (value['arrayValue']['values'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
      return arr.map(_restValue).toList();
    }
    if (value.containsKey('mapValue')) {
      final map = <String, dynamic>{};
      for (final entry in (value['mapValue']['fields'] as Map<String, dynamic>).entries) {
        map[entry.key] = _restValue(entry.value);
      }
      return map;
    }
    return value.toString();
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
