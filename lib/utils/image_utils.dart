/// Conditional export:
/// - Native: dùng dart:io (File) để hiển thị ảnh
/// - Web: không dùng dart:io, trả về placeholder

export 'image_utils_stub.dart' if (dart.library.io) 'image_utils_native.dart';
