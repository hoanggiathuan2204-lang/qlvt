class MaterialModel {
  int id;
  String maVatTu;
  String tenVatTu;
  String nhomVatTu;
  String donViTinh;
  int soLuongTon;
  int mucCanhBao;
  double giaNhap;
  String nhaCungCap;

  MaterialModel({
    required this.id,
    required this.maVatTu,
    required this.tenVatTu,
    required this.nhomVatTu,
    required this.donViTinh,
    required this.soLuongTon,
    required this.mucCanhBao,
    required this.giaNhap,
    required this.nhaCungCap,
  });

  MaterialModel copyWith({
    int? id,
    String? maVatTu,
    String? tenVatTu,
    String? nhomVatTu,
    String? donViTinh,
    int? soLuongTon,
    int? mucCanhBao,
    double? giaNhap,
    String? nhaCungCap,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      maVatTu: maVatTu ?? this.maVatTu,
      tenVatTu: tenVatTu ?? this.tenVatTu,
      nhomVatTu: nhomVatTu ?? this.nhomVatTu,
      donViTinh: donViTinh ?? this.donViTinh,
      soLuongTon: soLuongTon ?? this.soLuongTon,
      mucCanhBao: mucCanhBao ?? this.mucCanhBao,
      giaNhap: giaNhap ?? this.giaNhap,
      nhaCungCap: nhaCungCap ?? this.nhaCungCap,
    );
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: _toInt(map['id']),
      maVatTu: _toString(map['maVatTu']),
      tenVatTu: _toString(map['tenVatTu']),
      nhomVatTu: _toString(map['nhomVatTu']),
      donViTinh: _toString(map['donViTinh']),
      soLuongTon: _toInt(map['soLuongTon']),
      mucCanhBao: _toInt(map['mucCanhBao']),
      giaNhap: _toDouble(map['giaNhap']),
      nhaCungCap: _toString(map['nhaCungCap']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) "id": id,
      "maVatTu": maVatTu,
      "tenVatTu": tenVatTu,
      "nhomVatTu": nhomVatTu,
      "donViTinh": donViTinh,
      "soLuongTon": soLuongTon,
      "mucCanhBao": mucCanhBao,
      "giaNhap": giaNhap,
      "nhaCungCap": nhaCungCap,
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
}
