import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/delivery_model.dart';
import '../models/export_model.dart';
import '../models/import_model.dart';
import '../models/material_model.dart';
import '../models/product_model.dart';
import '../models/supplier_model.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  //--------------------------------------------------
  // DATABASE
  //--------------------------------------------------

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  //--------------------------------------------------
  // INIT DATABASE
  //--------------------------------------------------

  Future<Database> _initDatabase() async {
    Directory folder;
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final docs = await getApplicationDocumentsDirectory();
        folder = Directory(join(docs.path, 'AnhDuongERP'));
      } else {
        final docs = await getApplicationDocumentsDirectory();
        folder = Directory(join(docs.path, 'AnhDuongERP'));
      }
    } catch (_) {
      folder = Directory(join(await getDatabasesPath(), 'AnhDuongERP'));
    }

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final dbPath = join(folder.path, 'qlvt.db');

    print('======================================');
    print('Database Folder : ${folder.path}');
    print('Database File   : $dbPath');
    print('DB Exists       : ${await File(dbPath).exists()}');
    print('======================================');

    return openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  //--------------------------------------------------
  // CREATE TABLE
  //--------------------------------------------------

  Future<void> _onCreate(Database db, int version) async {
    await _createAllTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE IF NOT EXISTS suppliers(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maNCC TEXT NOT NULL,
  tenNCC TEXT NOT NULL,
  diaChi TEXT,
  soDienThoai TEXT,
  email TEXT,
  nguoiLienHe TEXT,
  ghiChu TEXT,
  ngayTao TEXT
)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS import_history(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  materialId INTEGER,
  maVatTu TEXT,
  tenVatTu TEXT,
  soLuong INTEGER,
  donGia REAL,
  nhaCungCap TEXT,
  nguoiNhap TEXT,
  ghiChu TEXT,
  thoiGian TEXT
)
''');

      await db.execute('''
CREATE TABLE IF NOT EXISTS export_history(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  materialId INTEGER,
  maVatTu TEXT,
  tenVatTu TEXT,
  soLuong INTEGER,
  nguoiXuat TEXT,
  lyDo TEXT,
  ghiChu TEXT,
  thoiGian TEXT
)
''');
    }
  }

  Future<void> _createAllTables(Database db) async {
    await db.execute('''
CREATE TABLE materials(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maVatTu TEXT NOT NULL,
  tenVatTu TEXT NOT NULL,
  nhomVatTu TEXT,
  donViTinh TEXT,
  soLuongTon INTEGER,
  mucCanhBao INTEGER,
  giaNhap REAL,
  nhaCungCap TEXT
)
''');

    await db.execute('''
CREATE TABLE products(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maSanPham TEXT,
  tenSanPham TEXT,
  donVi TEXT,
  soKien INTEGER,
  diaChiLapRap TEXT,
  ngayTao TEXT
)
''');

    await db.execute('''
CREATE TABLE deliveries(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tenSanPham TEXT,
  soKien INTEGER,
  diaChiGiao TEXT,
  nguoiBocHang TEXT,
  taiXe TEXT,
  bienSoXe TEXT,
  thoiGian TEXT,
  ghiChu TEXT,
  imagePath TEXT
)
''');

    await db.execute('''
CREATE TABLE suppliers(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  maNCC TEXT NOT NULL,
  tenNCC TEXT NOT NULL,
  diaChi TEXT,
  soDienThoai TEXT,
  email TEXT,
  nguoiLienHe TEXT,
  ghiChu TEXT,
  ngayTao TEXT
)
''');

    await db.execute('''
CREATE TABLE import_history(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  materialId INTEGER,
  maVatTu TEXT,
  tenVatTu TEXT,
  soLuong INTEGER,
  donGia REAL,
  nhaCungCap TEXT,
  nguoiNhap TEXT,
  ghiChu TEXT,
  thoiGian TEXT
)
''');

    await db.execute('''
CREATE TABLE export_history(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  materialId INTEGER,
  maVatTu TEXT,
  tenVatTu TEXT,
  soLuong INTEGER,
  nguoiXuat TEXT,
  lyDo TEXT,
  ghiChu TEXT,
  thoiGian TEXT
)
''');
  }

  //====================================================
  // MATERIAL
  //====================================================

  Future<int> addMaterial(MaterialModel material) async {
    final db = await database;
    return db.insert(
      'materials',
      material.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MaterialModel>> getMaterials() async {
    final db = await database;
    final maps = await db.query('materials', orderBy: 'id DESC');
    return maps.map((e) => MaterialModel.fromMap(e)).toList();
  }

  Future<int> updateMaterial(MaterialModel material) async {
    final db = await database;
    return db.update(
      'materials',
      material.toMap(),
      where: 'id=?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteMaterial(int id) async {
    final db = await database;
    return db.delete('materials', where: 'id=?', whereArgs: [id]);
  }

  Future<MaterialModel?> getMaterial(int id) async {
    final db = await database;
    final maps = await db.query(
      'materials',
      where: 'id=?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return MaterialModel.fromMap(maps.first);
  }

  //====================================================
  // PRODUCT
  //====================================================

  Future<int> addProduct(ProductModel product) async {
    final db = await database;
    return db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProductModel>> getProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'id DESC');
    return maps.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<int> updateProduct(ProductModel product) async {
    final db = await database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id=?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id=?', whereArgs: [id]);
  }

  Future<ProductModel?> getProduct(int id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id=?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ProductModel.fromMap(maps.first);
  }

  //====================================================
  // DELIVERY
  //====================================================

  Future<int> addDelivery(DeliveryModel delivery) async {
    final db = await database;
    return db.insert(
      'deliveries',
      delivery.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DeliveryModel>> getDeliveries() async {
    final db = await database;
    final maps = await db.query('deliveries', orderBy: 'id DESC');
    return maps.map((e) => DeliveryModel.fromMap(e)).toList();
  }

  Future<int> updateDelivery(DeliveryModel delivery) async {
    final db = await database;
    return db.update(
      'deliveries',
      delivery.toMap(),
      where: 'id=?',
      whereArgs: [delivery.id],
    );
  }

  Future<int> deleteDelivery(int id) async {
    final db = await database;
    return db.delete('deliveries', where: 'id=?', whereArgs: [id]);
  }

  Future<DeliveryModel?> getDelivery(int id) async {
    final db = await database;
    final maps = await db.query(
      'deliveries',
      where: 'id=?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return DeliveryModel.fromMap(maps.first);
  }

  Future<void> clearDeliveries() async {
    final db = await database;
    await db.delete('deliveries');
  }

  //====================================================
  // SUPPLIER
  //====================================================

  Future<int> addSupplier(SupplierModel supplier) async {
    final db = await database;
    return db.insert(
      'suppliers',
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SupplierModel>> getSuppliers() async {
    final db = await database;
    final maps = await db.query('suppliers', orderBy: 'tenNCC ASC');
    return maps.map((e) => SupplierModel.fromMap(e)).toList();
  }

  Future<int> updateSupplier(SupplierModel supplier) async {
    final db = await database;
    return db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id=?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return db.delete('suppliers', where: 'id=?', whereArgs: [id]);
  }

  //====================================================
  // IMPORT HISTORY
  //====================================================

  Future<int> addImportHistory(ImportModel record) async {
    final db = await database;
    return db.insert(
      'import_history',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ImportModel>> getImportHistory() async {
    final db = await database;
    final maps = await db.query('import_history', orderBy: 'id DESC');
    return maps.map((e) => ImportModel.fromMap(e)).toList();
  }

  Future<List<ImportModel>> getImportHistoryByMaterial(int materialId) async {
    final db = await database;
    final maps = await db.query(
      'import_history',
      where: 'materialId=?',
      whereArgs: [materialId],
      orderBy: 'id DESC',
    );
    return maps.map((e) => ImportModel.fromMap(e)).toList();
  }

  Future<int> deleteImportHistory(int id) async {
    final db = await database;
    return db.delete('import_history', where: 'id=?', whereArgs: [id]);
  }

  //====================================================
  // EXPORT HISTORY
  //====================================================

  Future<int> addExportHistory(ExportModel record) async {
    final db = await database;
    return db.insert(
      'export_history',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExportModel>> getExportHistory() async {
    final db = await database;
    final maps = await db.query('export_history', orderBy: 'id DESC');
    return maps.map((e) => ExportModel.fromMap(e)).toList();
  }

  Future<List<ExportModel>> getExportHistoryByMaterial(int materialId) async {
    final db = await database;
    final maps = await db.query(
      'export_history',
      where: 'materialId=?',
      whereArgs: [materialId],
      orderBy: 'id DESC',
    );
    return maps.map((e) => ExportModel.fromMap(e)).toList();
  }

  Future<int> deleteExportHistory(int id) async {
    final db = await database;
    return db.delete('export_history', where: 'id=?', whereArgs: [id]);
  }

  //====================================================
  // CLOSE
  //====================================================

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
