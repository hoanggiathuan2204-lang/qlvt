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
    final snapshot = await materialsRef.orderBy('tenVatTu').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MaterialModel.fromMap({...data, 'id': int.tryParse(doc.id) ?? 0});
    }).toList();
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
    final snapshot = await productsRef.orderBy('tenSanPham').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductModel.fromMap({...data, 'id': int.tryParse(doc.id) ?? 0});
    }).toList();
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
    final snapshot = await suppliersRef.orderBy('tenNCC').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return SupplierModel.fromMap({...data, 'id': int.tryParse(doc.id) ?? 0});
    }).toList();
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
    final snapshot = await deliveriesRef
        .orderBy('thoiGian', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DeliveryModel.fromMap({...data, 'id': int.tryParse(doc.id) ?? 0});
    }).toList();
  }

  static Future<int> addDelivery(DeliveryModel delivery) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await deliveriesRef.doc(id).set(delivery.toMap()..['id'] = int.parse(id));
    return int.parse(id);
  }

  static Future<void> updateDelivery(DeliveryModel delivery) async {
    if (delivery.id == 0) return;
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
}
