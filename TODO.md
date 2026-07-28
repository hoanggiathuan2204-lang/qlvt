# TODO: Fix Flutter Web Build

## Mục tiêu
Fix lỗi build web và đảm bảo đồng bộ dữ liệu giữa Web và App qua Firestore.

## Các bước thực hiện

### Bước 1: Fix `lib/database/app_database.dart` ✅
- Sử dụng conditional export (`dart.library.io`) để web dùng stub, native dùng SQLite thật.

### Bước 2: Fix `lib/screens/delivery_history_screen.dart` ✅
- Xóa `import 'dart:io'`
- Dùng `image_utils` wrapper để xử lý ảnh cross-platform

### Bước 3: Fix `lib/widgets/delivery_dialog.dart` ✅
- Xóa `import 'dart:io'`, `import 'package:path_provider/...'`, `import 'package:path/...'`
- Xóa `Image.file` dùng placeholder text
- Giữ chức năng chọn ảnh qua `FilePicker`

### Bước 4: Kiểm tra build web ✅
- `flutter build web --release` **thành công** ✅
- File `main.dart.js` đã được tạo, không lỗi compile

## Kết quả
✅ Đã fix thành công! App có thể build cho cả web và native.

