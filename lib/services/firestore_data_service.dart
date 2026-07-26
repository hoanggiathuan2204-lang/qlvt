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
      final snapshot = await materialsRef.orderBy('tenVatTu').get();
      final list = <MaterialModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          list.add(MaterialModel.fromMap({...data, 'id': _safeInt(doc.id)}));
        } catch (e) {
          continue;
        }
      }
      return list;
    } catch (e) {
      rethrow;
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
      final snapshot = await productsRef.orderBy('tenSanPham').get();
      final list = <ProductModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          list.add(ProductModel.fromMap({...data, 'id': _safeInt(doc.id)}));
        } catch (e) {
          continue;
        }
      }
      return list;
    } catch (e) {
      rethrow;
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
      final snapshot = await suppliersRef.orderBy('tenNCC').get();
      final list = <SupplierModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          list.add(SupplierModel.fromMap({...data, 'id': _safeInt(doc.id)}));
        } catch (e) {
          continue;
        }
      }
      return list;
    } catch (e) {
      rethrow;
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
      final snapshot = await deliveriesRef
          .orderBy('thoiGian', descending: true)
          .get();
      final list = <DeliveryModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          list.add(DeliveryModel.fromMap({...data, 'id': _safeInt(doc.id)}));
        } catch (e) {
          continue;
        }
      }
      return list;
    } catch (e) {
      rethrow;
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

  static int _safeInt(String value) {
    return int.tryParse(value) ?? DateTime.now().millisecondsSinceEpoch;
  }
}
