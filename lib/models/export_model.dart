class ExportModel {
  int id;
  int materialId;
  String maVatTu;
  String tenVatTu;
  int soLuong;
  String nguoiXuat;
  String lyDo;
  String ghiChu;
  DateTime thoiGian;

  ExportModel({
    required this.id,
    required this.materialId,
    required this.maVatTu,
    required this.tenVatTu,
    required this.soLuong,
    required this.nguoiXuat,
    required this.lyDo,
    required this.ghiChu,
    required this.thoiGian,
  });

  ExportModel copyWith({
    int? id,
    int? materialId,
    String? maVatTu,
    String? tenVatTu,
    int? soLuong,
    String? nguoiXuat,
    String? lyDo,
    String? ghiChu,
    DateTime? thoiGian,
  }) {
    return ExportModel(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      maVatTu: maVatTu ?? this.maVatTu,
      tenVatTu: tenVatTu ?? this.tenVatTu,
      soLuong: soLuong ?? this.soLuong,
      nguoiXuat: nguoiXuat ?? this.nguoiXuat,
      lyDo: lyDo ?? this.lyDo,
      ghiChu: ghiChu ?? this.ghiChu,
      thoiGian: thoiGian ?? this.thoiGian,
    );
  }

  factory ExportModel.fromMap(Map<String, dynamic> map) {
    return ExportModel(
      id: _toInt(map['id']),
      materialId: _toInt(map['materialId']),
      maVatTu: _toString(map['maVatTu']),
      tenVatTu: _toString(map['tenVatTu']),
      soLuong: _toInt(map['soLuong']),
      nguoiXuat: _toString(map['nguoiXuat']),
      lyDo: _toString(map['lyDo']),
      ghiChu: _toString(map['ghiChu']),
      thoiGian: _toDate(map['thoiGian']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'materialId': materialId,
      'maVatTu': maVatTu,
      'tenSanPham': tenVatTu,
      'soLuong': soLuong,
      'nguoiXuat': nguoiXuat,
      'lyDo': lyDo,
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

  static String _toString(dynamic value) {
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  static DateTime? _toDate(dynamic value) {
    if (value is DateTime) return value;
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
