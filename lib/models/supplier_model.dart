import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierModel {
  int id;
  String maNCC;
  String tenNCC;
  String diaChi;
  String soDienThoai;
  String email;
  String nguoiLienHe;
  String ghiChu;
  DateTime ngayTao;
  String? userId;

  SupplierModel({
    required this.id,
    required this.maNCC,
    required this.tenNCC,
    required this.diaChi,
    required this.soDienThoai,
    required this.email,
    required this.nguoiLienHe,
    required this.ghiChu,
    required this.ngayTao,
    this.userId,
  });

  SupplierModel copyWith({
    int? id,
    String? maNCC,
    String? tenNCC,
    String? diaChi,
    String? soDienThoai,
    String? email,
    String? nguoiLienHe,
    String? ghiChu,
    DateTime? ngayTao,
    String? userId,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      maNCC: maNCC ?? this.maNCC,
      tenNCC: tenNCC ?? this.tenNCC,
      diaChi: diaChi ?? this.diaChi,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      email: email ?? this.email,
      nguoiLienHe: nguoiLienHe ?? this.nguoiLienHe,
      ghiChu: ghiChu ?? this.ghiChu,
      ngayTao: ngayTao ?? this.ngayTao,
      userId: userId ?? this.userId,
    );
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: _toInt(map['id']),
      maNCC: _toString(map['maNCC']),
      tenNCC: _toString(map['tenNCC']),
      diaChi: _toString(map['diaChi']),
      soDienThoai: _toString(map['soDienThoai']),
      email: _toString(map['email']),
      nguoiLienHe: _toString(map['nguoiLienHe']),
      ghiChu: _toString(map['ghiChu']),
      ngayTao: _toDate(map['ngayTao']) ?? DateTime.now(),
      userId: _toStringOrNull(map['userId']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'maNCC': maNCC,
      'tenNCC': tenNCC,
      'diaChi': diaChi,
      'soDienThoai': soDienThoai,
      'email': email,
      'nguoiLienHe': nguoiLienHe,
      'ghiChu': ghiChu,
      'ngayTao': ngayTao.toIso8601String(),
      if (userId != null) 'userId': userId,
    };
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value == null) return 0;
    return 0;
  }

  static String _toString(dynamic value) {
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  static DateTime? _toDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
