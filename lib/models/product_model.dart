class ProductModel {
  int id;
  String maSanPham;
  String tenSanPham;
  String donVi;
  int soKien;
  String diaChiLapRap;
  DateTime ngayTao;

  ProductModel({
    required this.id,
    required this.maSanPham,
    required this.tenSanPham,
    required this.donVi,
    required this.soKien,
    required this.diaChiLapRap,
    required this.ngayTao,
  });

  ProductModel copyWith({
    int? id,
    String? maSanPham,
    String? tenSanPham,
    String? donVi,
    int? soKien,
    String? diaChiLapRap,
    DateTime? ngayTao,
  }) {
    return ProductModel(
      id: id ?? this.id,
      maSanPham: maSanPham ?? this.maSanPham,
      tenSanPham: tenSanPham ?? this.tenSanPham,
      donVi: donVi ?? this.donVi,
      soKien: soKien ?? this.soKien,
      diaChiLapRap: diaChiLapRap ?? this.diaChiLapRap,
      ngayTao: ngayTao ?? this.ngayTao,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: _toInt(map['id']),
      maSanPham: _toString(map['maSanPham']),
      tenSanPham: _toString(map['tenSanPham']),
      donVi: _toString(map['donVi']),
      soKien: _toInt(map['soKien']),
      diaChiLapRap: _toString(map['diaChiLapRap']),
      ngayTao: _toDate(map['ngayTao']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'maSanPham': maSanPham,
      'tenSanPham': tenSanPham,
      'donVi': donVi,
      'soKien': soKien,
      'diaChiLapRap': diaChiLapRap,
      'ngayTao': ngayTao.toIso8601String(),
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
