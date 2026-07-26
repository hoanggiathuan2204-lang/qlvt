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
      id: map["id"] ?? 0,
      maVatTu: map["maVatTu"] ?? "",
      tenVatTu: map["tenVatTu"] ?? "",
      nhomVatTu: map["nhomVatTu"] ?? "",
      donViTinh: map["donViTinh"] ?? "",
      soLuongTon: map["soLuongTon"] ?? 0,
      mucCanhBao: map["mucCanhBao"] ?? 0,
      giaNhap: (map["giaNhap"] ?? 0).toDouble(),
      nhaCungCap: map["nhaCungCap"] ?? "",
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

  @override
  String toString() {
    return 'MaterialModel('
        'id: $id, '
        'maVatTu: $maVatTu, '
        'tenVatTu: $tenVatTu, '
        'nhomVatTu: $nhomVatTu, '
        'donViTinh: $donViTinh, '
        'soLuongTon: $soLuongTon, '
        'mucCanhBao: $mucCanhBao, '
        'giaNhap: $giaNhap, '
        'nhaCungCap: $nhaCungCap'
        ')';
  }
}
