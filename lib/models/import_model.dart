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
      id: map['id'] ?? 0,
      materialId: map['materialId'] ?? 0,
      maVatTu: map['maVatTu'] ?? '',
      tenVatTu: map['tenVatTu'] ?? '',
      soLuong: map['soLuong'] ?? 0,
      donGia: (map['donGia'] ?? 0).toDouble(),
      nhaCungCap: map['nhaCungCap'] ?? '',
      nguoiNhap: map['nguoiNhap'] ?? '',
      ghiChu: map['ghiChu'] ?? '',
      thoiGian: map['thoiGian'] != null
          ? DateTime.parse(map['thoiGian'])
          : DateTime.now(),
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
}
