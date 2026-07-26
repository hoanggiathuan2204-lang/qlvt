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

  //------------------------------------------------
  // Copy
  //------------------------------------------------

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

  //------------------------------------------------
  // From Map
  //------------------------------------------------

  factory DeliveryModel.fromMap(Map<String, dynamic> map) {
    return DeliveryModel(
      id: map["id"] ?? 0,
      tenSanPham: map["tenSanPham"] ?? "",
      soKien: map["soKien"] ?? 0,
      diaChiGiao: map["diaChiGiao"] ?? "",
      nguoiBocHang: map["nguoiBocHang"] ?? "",
      taiXe: map["taiXe"] ?? "",
      bienSoXe: map["bienSoXe"] ?? "",
      thoiGian: map["thoiGian"] == null
          ? DateTime.now()
          : DateTime.parse(map["thoiGian"]),
      ghiChu: map["ghiChu"] ?? "",
      imagePath: map["imagePath"],
    );
  }

  //------------------------------------------------
  // To Map
  //------------------------------------------------

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

  //------------------------------------------------
  // Debug
  //------------------------------------------------

  @override
  String toString() {
    return '''
DeliveryModel(
id: $id,
tenSanPham: $tenSanPham,
soKien: $soKien,
diaChiGiao: $diaChiGiao,
nguoiBocHang: $nguoiBocHang,
taiXe: $taiXe,
bienSoXe: $bienSoXe,
thoiGian: $thoiGian,
ghiChu: $ghiChu,
imagePath: $imagePath
)
''';
  }
}
