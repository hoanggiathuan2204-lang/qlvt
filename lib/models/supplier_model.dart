class SupplierModel {
  int id;
  String maNCC;
  String tenNCC;
  String diaChi;
  String soDienThoai;
  String email;
  String nguoiLienHe;
  String ghiChu;
  DateTime ngayTao;

  SupplierModel({
    required this.id,
    required this.maNCC,
    required this.tenNCC,
    required this.diaChi,
    required this.soDienThoai,
    required this.email,
    required this.nguoiLienHe,
    required this.ghiChu,
    required this.ngayTao,
  });

  SupplierModel copyWith({
    int? id,
    String? maNCC,
    String? tenNCC,
    String? diaChi,
    String? soDienThoai,
    String? email,
    String? nguoiLienHe,
    String? ghiChu,
    DateTime? ngayTao,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      maNCC: maNCC ?? this.maNCC,
      tenNCC: tenNCC ?? this.tenNCC,
      diaChi: diaChi ?? this.diaChi,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      email: email ?? this.email,
      nguoiLienHe: nguoiLienHe ?? this.nguoiLienHe,
      ghiChu: ghiChu ?? this.ghiChu,
      ngayTao: ngayTao ?? this.ngayTao,
    );
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] ?? 0,
      maNCC: map['maNCC'] ?? '',
      tenNCC: map['tenNCC'] ?? '',
      diaChi: map['diaChi'] ?? '',
      soDienThoai: map['soDienThoai'] ?? '',
      email: map['email'] ?? '',
      nguoiLienHe: map['nguoiLienHe'] ?? '',
      ghiChu: map['ghiChu'] ?? '',
      ngayTao: map['ngayTao'] != null
          ? DateTime.parse(map['ngayTao'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'maNCC': maNCC,
      'tenNCC': tenNCC,
      'diaChi': diaChi,
      'soDienThoai': soDienThoai,
      'email': email,
      'nguoiLienHe': nguoiLienHe,
      'ghiChu': ghiChu,
      'ngayTao': ngayTao.toIso8601String(),
    };
  }

  @override
  String toString() => 'SupplierModel(id:$id, maNCC:$maNCC, tenNCC:$tenNCC)';
}
