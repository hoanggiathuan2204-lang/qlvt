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
      id: map['id'] ?? 0,
      materialId: map['materialId'] ?? 0,
      maVatTu: map['maVatTu'] ?? '',
      tenVatTu: map['tenVatTu'] ?? '',
      soLuong: map['soLuong'] ?? 0,
      nguoiXuat: map['nguoiXuat'] ?? '',
      lyDo: map['lyDo'] ?? '',
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
      'nguoiXuat': nguoiXuat,
      'lyDo': lyDo,
      'ghiChu': ghiChu,
      'thoiGian': thoiGian.toIso8601String(),
    };
  }
}
