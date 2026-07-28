import 'package:cloud_firestore/cloud_firestore.dart';

class ImportModel {
  int id;
  int materialId;
  String maVatTu;
  String tenVatTu;
  int soLuong;
  double donGia;
  String nhaCungCap;
  String nguoiNhap;
  String ghiChu;
  DateTime thoiGian;

  ImportModel({
    required this.id,
    required this.materialId,
    required this.maVatTu,
    required this.tenVatTu,
    required this.soLuong,
    required this.donGia,
    required this.nhaCungCap,
    required this.nguoiNhap,
    required this.ghiChu,
    required this.thoiGian,
  });

  ImportModel copyWith({
    int? id,
    int? materialId,
    String? maVatTu,
    String? tenVatTu,
    int? soLuong,
    double? donGia,
    String? nhaCungCap,
    String? nguoiNhap,
    String? ghiChu,
    DateTime? thoiGian,
  }) {
    return ImportModel(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      maVatTu: maVatTu ?? this.maVatTu,
      tenVatTu: tenVatTu ?? this.tenVatTu,
      soLuong: soLuong ?? this.soLuong,
      donGia: donGia ?? this.donGia,
      nhaCungCap: nhaCungCap ?? this.nhaCungCap,
      nguoiNhap: nguoiNhap ?? this.nguoiNhap,
      ghiChu: ghiChu ?? this.ghiChu,
      thoiGian: thoiGian ?? this.thoiGian,
    );
  }

  factory ImportModel.fromMap(Map<String, dynamic> map) {
    return ImportModel(
      id: _toInt(map['id']),
      materialId: _toInt(map['materialId']),
      maVatTu: _toString(map['maVatTu']),
      tenVatTu: _toString(map['tenVatTu']),
      soLuong: _toInt(map['soLuong']),
      donGia: _toDouble(map['donGia']),
      nhaCungCap: _toString(map['nhaCungCap']),
      nguoiNhap: _toString(map['nguoiNhap']),
      ghiChu: _toString(map['ghiChu']),
      thoiGian: _toDate(map['thoiGian']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'materialId': materialId,
      'maVatTu': maVatTu,
      'tenVatTu': tenVatTu,
      'soLuong': soLuong,
      'donGia': donGia,
      'nhaCungCap': nhaCungCap,
      'nguoiNhap': nguoiNhap,
      'ghiChu': ghiChu,
      'thoiGian': thoiGian.toIso8601String(),
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value == null) return 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value == null) return 0.0;
    return 0.0;
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
