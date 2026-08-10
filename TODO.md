# Kế hoạch tối ưu web thuần + giao diện giống code Flutter cũ

## Việc cần làm

- [x] 0. Phân tích code hiện tại (web thuần + Flutter cũ)
- [x] 1. Lên kế hoạch & được user duyệt

## Giao diện (style.css)
- [x] 2. Đổi theme sang màu cam giống Flutter:
  - `--primary: #F57C00`, `--primary-dark: #EF6C00`, `--accent: #FF9800`
  - `--sidebar-bg: #1C1C2E` (sidebar tối), hover `#2D2D44`
  - `--bg: #F5F6FA`, `--radius: 18px`
- [x] 3. Menu sidebar active: nền cam 18%, border cam 40%, thanh chỉ báo cam
- [x] 4. Dashboard card: icon chấm màu, value to in màu (giống DashboardCard)

## Tăng tốc
- [x] 5. Tối ưu `store.js`: count tận dụng cache (giảm truy vấn lặp)
- [x] 6. Dashboard đã dùng cache qua Store (không truy vấn count lặp)
- [x] 7. Gộp JS thành `dist/app.min.js`, cập nhật index.html

## Đóng gói
- [x] 8. Tạo `build_js.ps1` (gộp + nén JS thuần PowerShell, không cần node/python)
- [x] 9. Chạy build tạo `dist/app.min.js` thành công (~101 KB, gộp từ 14 file JS)
- [x] 10. `index.html` chỉ tải 1 file `dist/app.min.js`; CDN script dùng `defer`
- [x] 11. Xoá file trung gian `minify_js.py`

## Ghi chú
- CDN (Firebase SDK + Google Fonts) vẫn là phần tốn thời gian tải lớn nhất như đã phân tích; nếu cần giảm tiếp nên cân nhắc tải font nội bộ / gọn Firebase SDK.

