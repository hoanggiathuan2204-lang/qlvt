import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../models/delivery_model.dart';
import '../models/material_model.dart';
import '../models/notification_model.dart';
import '../models/product_model.dart';
import '../models/supplier_model.dart';
import 'auth_service.dart';

/// A simple change notifier that broadcasts data change events.
class DataChangeNotifier {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  /// Stream of change type descriptions (e.g. 'material', 'product', ...)
  Stream<String> get changes => _controller.stream;

  void notify(String type) {
    _controller.add(type);
  }

  void dispose() {
    _controller.close();
  }

  // Singleton
  static final DataChangeNotifier instance = DataChangeNotifier._();
  DataChangeNotifier._();
}

class FirestoreDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final DataChangeNotifier notifier = DataChangeNotifier.instance;

  static CollectionReference<Map<String, dynamic>> get materialsRef =>
      _db.collection('materials');

  static CollectionReference<Map<String, dynamic>> get productsRef =>
      _db.collection('products');

  static CollectionReference<Map<String, dynamic>> get suppliersRef =>
      _db.collection('suppliers');

  static CollectionReference<Map<String, dynamic>> get deliveriesRef =>
      _db.collection('deliveries');

  static CollectionReference<Map<String, dynamic>> get notificationsRef =>
      _db.collection('notifications');

  // ─── Notifications ────────────────────────────────────────

  /// Add a notification to Firestore about a user action.
  static Future<void> addNotification({
    required String action,
    required String description,
    required String targetType,
    required String targetId,
    required String targetName,
  }) async {
    try {
      var user = AuthService.instance.currentUser;
      String username;
      String displayName;
      String role;

      if (user != null) {
        username = user.username;
        displayName = user.displayName;
        role = user.role;
      } else {
        // Fallback to FirebaseAuth (useful on web where app-level AuthService
        // might not be populated yet)
        final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
        username = fbUser?.email ?? 'anonymous';
        displayName = fbUser?.displayName ?? username;
        role = 'user';
      }

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final notification = NotificationModel(
        id: id,
        action: action,
        description: description,
        userName: username,
        displayName: displayName,
        userRole: role,
        timestamp: DateTime.now(),
        targetType: targetType,
        targetId: targetId,
        targetName: targetName,
      );
      final data = notification.toMap();
      // Store timestamp as Firestore Timestamp for accurate ordering and queries
      data['timestamp'] = Timestamp.fromDate(notification.timestamp);
      await notificationsRef.doc(id).set(data);
    } catch (e) {
      print('[FS] addNotification FAILED: $e');
    }
  }

  /// Returns a realtime stream of notifications, newest first.
  static Stream<List<NotificationModel>> streamNotifications() {
    return notificationsRef
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          final list = <NotificationModel>[];
          for (final doc in snapshot.docs) {
            try {
              final raw = doc.data();
              if (raw is! Map) continue;
              final data = _toPlainMap(raw);
              // ensure id is the document id (string)
              data['id'] = doc.id.toString();
              list.add(NotificationModel.fromMap(data));
            } catch (e) {
              print('[FS] streamNotifications skip doc=${doc.id} err=$e');
              continue;
            }
          }
          return list;
        });
  }

  /// Get unread notification count (from last 24 hours).
  static Future<int> getUnreadNotificationCount() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      final snapshot = await notificationsRef
          .where('timestamp', isGreaterThan: Timestamp.fromDate(yesterday))
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // ─── Snapshot streams (realtime sync) ─────────────────────

  /// Returns a realtime stream of all materials, sorted by name.
  static Stream<List<MaterialModel>> streamMaterials() {
    return materialsRef.snapshots().map((snapshot) {
      final list = <MaterialModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          if (raw is! Map) continue;
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(MaterialModel.fromMap(data));
        } catch (e) {
          print('[FS] streamMaterials skip doc=${doc.id} err=$e');
          continue;
        }
      }
      list.sort(
        (a, b) => a.tenVatTu.toLowerCase().compareTo(b.tenVatTu.toLowerCase()),
      );
      return list;
    });
  }

  /// Returns a realtime stream of all products, sorted by name.
  static Stream<List<ProductModel>> streamProducts() {
    return productsRef.snapshots().map((snapshot) {
      final list = <ProductModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          if (raw is! Map) continue;
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(ProductModel.fromMap(data));
        } catch (e) {
          print('[FS] streamProducts skip doc=${doc.id} err=$e');
          continue;
        }
      }
      list.sort(
        (a, b) =>
            a.tenSanPham.toLowerCase().compareTo(b.tenSanPham.toLowerCase()),
      );
      return list;
    });
  }

  /// Returns a realtime stream of all suppliers, sorted by name.
  static Stream<List<SupplierModel>> streamSuppliers() {
    return suppliersRef.snapshots().map((snapshot) {
      final list = <SupplierModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          if (raw is! Map) continue;
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(SupplierModel.fromMap(data));
        } catch (e) {
          print('[FS] streamSuppliers skip doc=${doc.id} err=$e');
          continue;
        }
      }
      list.sort(
        (a, b) => a.tenNCC.toLowerCase().compareTo(b.tenNCC.toLowerCase()),
      );
      return list;
    });
  }

  /// Returns a realtime stream of all deliveries, sorted by time desc.
  static Stream<List<DeliveryModel>> streamDeliveries() {
    return deliveriesRef.orderBy('thoiGian', descending: true).snapshots().map((
      snapshot,
    ) {
      final list = <DeliveryModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          if (raw is! Map) continue;
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(DeliveryModel.fromMap(data));
        } catch (e) {
          print('[FS] streamDeliveries skip doc=${doc.id} err=$e');
          continue;
        }
      }
      return list;
    });
  }

  // ─── One-time fetches ─────────────────────────────────────

  static Future<List<MaterialModel>> getMaterials() async {
    try {
      final snapshot = await materialsRef.get();
      final list = <MaterialModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          if (raw is! Map) continue;
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
      return list;
    } catch (e) {
      print('[FS] getMaterials FAILED: $e');
      return <MaterialModel>[];
    }
  }

  static Future<void> addMaterial(MaterialModel material) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = material.toMap()..['id'] = int.parse(id);
      await materialsRef.doc(id).set(data);
      notifier.notify('material');
      addNotification(
        action: 'add',
        description: 'Thêm vật tư mới: ${material.tenVatTu}',
        targetType: 'material',
        targetId: id,
        targetName: material.tenVatTu,
      );
    } catch (e) {
      print('[FS] addMaterial FAILED: $e');
      throw Exception('Không thể thêm vật tư: $e');
    }
  }

  static Future<void> updateMaterial(MaterialModel material) async {
    if (material.id == 0) return;
    final data = material.toMap();
    await materialsRef.doc(material.id.toString()).set(data);
    notifier.notify('material');
    addNotification(
      action: 'update',
      description: 'Cập nhật vật tư: ${material.tenVatTu}',
      targetType: 'material',
      targetId: material.id.toString(),
      targetName: material.tenVatTu,
    );
  }

  static Future<void> deleteMaterial(int id) async {
    await materialsRef.doc(id.toString()).delete();
    notifier.notify('material');
    addNotification(
      action: 'delete',
      description: 'Xóa vật tư ID: $id',
      targetType: 'material',
      targetId: id.toString(),
      targetName: 'Vật tư #$id',
    );
  }

  static Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await productsRef.get();
      final list = <ProductModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          if (raw is! Map) continue;
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
      return list;
    } catch (e) {
      print('[FS] getProducts FAILED: $e');
      return <ProductModel>[];
    }
  }

  static Future<void> addProduct(ProductModel product) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = product.toMap()..['id'] = int.parse(id);
      await productsRef.doc(id).set(data);
      notifier.notify('product');
      addNotification(
        action: 'add',
        description: 'Thêm thành phẩm mới: ${product.tenSanPham}',
        targetType: 'product',
        targetId: id,
        targetName: product.tenSanPham,
      );
    } catch (e) {
      print('[FS] addProduct FAILED: $e');
      throw Exception('Không thể thêm thành phẩm: $e');
    }
  }

  static Future<void> updateProduct(ProductModel product) async {
    if (product.id == 0) return;
    await productsRef.doc(product.id.toString()).set(product.toMap());
    notifier.notify('product');
    addNotification(
      action: 'update',
      description: 'Cập nhật thành phẩm: ${product.tenSanPham}',
      targetType: 'product',
      targetId: product.id.toString(),
      targetName: product.tenSanPham,
    );
  }

  static Future<void> deleteProduct(int id) async {
    await productsRef.doc(id.toString()).delete();
    notifier.notify('product');
    addNotification(
      action: 'delete',
      description: 'Xóa thành phẩm ID: $id',
      targetType: 'product',
      targetId: id.toString(),
      targetName: 'Thành phẩm #$id',
    );
  }

  static Future<List<SupplierModel>> getSuppliers() async {
    try {
      final snapshot = await suppliersRef.get();
      final list = <SupplierModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          if (raw is! Map) continue;
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
      return list;
    } catch (e) {
      print('[FS] getSuppliers FAILED: $e');
      return <SupplierModel>[];
    }
  }

  static Future<int> addSupplier(SupplierModel supplier) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = supplier.toMap()..['id'] = int.parse(id);
      await suppliersRef.doc(id).set(data);
      notifier.notify('supplier');
      addNotification(
        action: 'add',
        description: 'Thêm nhà cung cấp mới: ${supplier.tenNCC}',
        targetType: 'supplier',
        targetId: id,
        targetName: supplier.tenNCC,
      );
      return int.parse(id);
    } catch (e) {
      print('[FS] addSupplier FAILED: $e');
      throw Exception('Không thể thêm nhà cung cấp: $e');
    }
  }

  static Future<void> updateSupplier(SupplierModel supplier) async {
    if (supplier.id == 0) return;
    await suppliersRef.doc(supplier.id.toString()).set(supplier.toMap());
    notifier.notify('supplier');
    addNotification(
      action: 'update',
      description: 'Cập nhật nhà cung cấp: ${supplier.tenNCC}',
      targetType: 'supplier',
      targetId: supplier.id.toString(),
      targetName: supplier.tenNCC,
    );
  }

  static Future<void> deleteSupplier(int id) async {
    await suppliersRef.doc(id.toString()).delete();
    notifier.notify('supplier');
    addNotification(
      action: 'delete',
      description: 'Xóa nhà cung cấp ID: $id',
      targetType: 'supplier',
      targetId: id.toString(),
      targetName: 'Nhà cung cấp #$id',
    );
  }

  static Future<List<DeliveryModel>> getDeliveries() async {
    try {
      final snapshot = await deliveriesRef.get();
      final list = <DeliveryModel>[];
      for (final doc in snapshot.docs) {
        try {
          final raw = doc.data();
          if (raw is! Map) continue;
          final data = _toPlainMap(raw);
          data['id'] = _safeInt(doc.id);
          list.add(DeliveryModel.fromMap(data));
        } catch (e) {
          print('[FS] getDeliveries skip doc=${doc.id} err=$e');
          continue;
        }
      }
      list.sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
      return list;
    } catch (e) {
      print('[FS] getDeliveries FAILED: $e');
      return <DeliveryModel>[];
    }
  }

  static Future<int> addDelivery(DeliveryModel delivery) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final data = delivery.toMap()..['id'] = int.parse(id);
      await deliveriesRef.doc(id).set(data);
      notifier.notify('delivery');
      addNotification(
        action: 'deliver',
        description:
            'Tạo phiếu giao: ${delivery.tenSanPham} (${delivery.soKien} kiện)',
        targetType: 'delivery',
        targetId: id,
        targetName: delivery.tenSanPham,
      );
      return int.parse(id);
    } catch (e) {
      print('[FS] addDelivery FAILED: $e');
      throw Exception('Không thể thêm phiếu giao: $e');
    }
  }

  static Future<void> updateDelivery(DeliveryModel delivery) async {
    await deliveriesRef.doc(delivery.id.toString()).set(delivery.toMap());
    notifier.notify('delivery');
    addNotification(
      action: 'update',
      description: 'Cập nhật phiếu giao: ${delivery.tenSanPham}',
      targetType: 'delivery',
      targetId: delivery.id.toString(),
      targetName: delivery.tenSanPham,
    );
  }

  static Future<void> deleteDelivery(int id) async {
    await deliveriesRef.doc(id.toString()).delete();
    notifier.notify('delivery');
    addNotification(
      action: 'delete',
      description: 'Xóa phiếu giao ID: $id',
      targetType: 'delivery',
      targetId: id.toString(),
      targetName: 'Phiếu giao #$id',
    );
  }

  static Future<void> clearDeliveries() async {
    final snapshot = await deliveriesRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    notifier.notify('delivery');
  }

  static Map<String, dynamic> _toPlainMap(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
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
      if (value is DateTime) {
        result[k] = value.toIso8601String();
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
        result[k] = value.map((e) {
          if (e == null) return null;
          if (e is String || e is int || e is double || e is bool) return e;
          if (e is Timestamp) return e.toDate().toIso8601String();
          if (e is DateTime) return e.toIso8601String();
          if (e is Map) return _toPlainMap(e);
          return e.toString();
        }).toList();
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
