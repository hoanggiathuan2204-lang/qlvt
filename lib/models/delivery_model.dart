class DeliveryModel {
  int id;
  String tenSanPham;
  int soKien;
  String diaChiGiao;
  String nguoiBocHang;
  String taiXe;
  String bienSoXe;
  DateTime thoiGian;
  String ghiChu;
  String? imagePath;

  DeliveryModel({
    required this.id,
    required this.tenSanPham,
    required this.soKien,
    required this.diaChiGiao,
    required this.nguoiBocHang,
    required this.taiXe,
    required this.bienSoXe,
    required this.thoiGian,
    required this.ghiChu,
    this.imagePath,
  });

  DeliveryModel copyWith({
    int? id,
    String? tenSanPham,
    int? soKien,
    String? diaChiGiao,
    String? nguoiBocHang,
    String? taiXe,
    String? bienSoXe,
    DateTime? thoiGian,
    String? ghiChu,
    String? imagePath,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      tenSanPham: tenSanPham ?? this.tenSanPham,
      soKien: soKien ?? this.soKien,
      diaChiGiao: diaChiGiao ?? this.diaChiGiao,
      nguoiBocHang: nguoiBocHang ?? this.nguoiBocHang,
      taiXe: taiXe ?? this.taiXe,
      bienSoXe: bienSoXe ?? this.bienSoXe,
      thoiGian: thoiGian ?? this.thoiGian,
      ghiChu: ghiChu ?? this.ghiChu,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory DeliveryModel.fromMap(Map<String, dynamic> map) {
    return DeliveryModel(
      id: _toInt(map['id']),
      tenSanPham: _toString(map['tenSanPham']),
      soKien: _toInt(map['soKien']),
      diaChiGiao: _toString(map['diaChiGiao']),
      nguoiBocHang: _toString(map['nguoiBocHang']),
      taiXe: _toString(map['taiXe']),
      bienSoXe: _toString(map['bienSoXe']),
      thoiGian: _toDate(map['thoiGian']) ?? DateTime.now(),
      ghiChu: _toString(map['ghiChu']),
      imagePath: _toStringOrNull(map['imagePath']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) "id": id,
      "tenSanPham": tenSanPham,
      "soKien": soKien,
      "diaChiGiao": diaChiGiao,
      "nguoiBocHang": nguoiBocHang,
      "taiXe": taiXe,
      "bienSoXe": bienSoXe,
      "thoiGian": thoiGian.toIso8601String(),
      "ghiChu": ghiChu,
      "imagePath": imagePath,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _toString(dynamic value) {
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
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
