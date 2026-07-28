/// Conditional export:
/// - Native (Android/iOS/Desktop): dùng SQLite thật
/// - Web: dùng stub (vì sqflite không hỗ trợ web)
/// Dữ liệu đồng bộ qua Firestore nên không cần database local trên web.

export 'app_database_stub.dart' if (dart.library.io) 'app_database_native.dart';
