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

  //------------------------------------------------
  // Copy
  //------------------------------------------------

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

  //------------------------------------------------
  // From Map
  //------------------------------------------------

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map["id"] ?? 0,
      maSanPham: map["maSanPham"] ?? "",
      tenSanPham: map["tenSanPham"] ?? "",
      donVi: map["donVi"] ?? "",
      soKien: map["soKien"] ?? 0,
      diaChiLapRap: map["diaChiLapRap"] ?? "",
      ngayTao: map["ngayTao"] == null
          ? DateTime.now()
          : DateTime.parse(map["ngayTao"]),
    );
  }

  //------------------------------------------------
  // To Map
  //------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) "id": id,
      "maSanPham": maSanPham,
      "tenSanPham": tenSanPham,
      "donVi": donVi,
      "soKien": soKien,
      "diaChiLapRap": diaChiLapRap,
      "ngayTao": ngayTao.toIso8601String(),
    };
  }

  //------------------------------------------------
  // Debug
  //------------------------------------------------

  @override
  String toString() {
    return '''
ProductModel(
id: $id,
maSanPham: $maSanPham,
tenSanPham: $tenSanPham,
donVi: $donVi,
soKien: $soKien,
diaChiLapRap: $diaChiLapRap,
ngayTao: $ngayTao
)
''';
  }
}
