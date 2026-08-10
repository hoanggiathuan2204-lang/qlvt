# QLVT - ERP Ánh Dương (Web thuần)

Ứng dụng web thuần (HTML/CSS/JavaScript) thay thế bản Flutter, dùng chung
Firebase Firestore với bản cũ nên **toàn bộ dữ liệu hiện tại vẫn hiển thị**.

## Tính năng

- **Đăng nhập**: tài khoản cục bộ (`owner`, `ketoan1`, `ketoan2`, `user1`, `user2` — mật khẩu `123`) hoặc Firebase email/mật khẩu.
- **Dashboard**: 6 chỉ số KPI + giao hàng gần đây + cảnh báo tồn kho.
- **Quản lý vật tư**: thêm/sửa/xóa, tìm kiếm, nhập/xuất kho (cập nhật tồn kho).
- **Nhà cung cấp**: thêm/sửa/xóa, tự sinh mã `NCC001`...
- **Thành phẩm**: thêm/sửa/xóa, đếm số kiện, xuất tạo phiếu giao hàng.
- **Lịch sử giao hàng**: danh sách phiếu giao + ảnh + xóa.
- **Báo cáo**: 6 KPI + 3 tab (Nhập kho / Xuất kho / Cảnh báo).
- **Thông báo**: chuông cập nhật thời gian thực + trang thông báo đầy đủ.
- **Responsive**: sidebar trên desktop, drawer trên mobile.

## Cấu trúc

```
index.html
css/style.css
js/
  config.js      Firebase config + tài khoản cục bộ
  firebase.js    Khởi tạo Firebase + wrapper CRUD
  store.js       Tầng dữ liệu (cache + ghi/đọc Firestore)
  auth.js        Phiên đăng nhập + phân quyền
  ui.js          toast, modal, confirm, định dạng
  app.js         SPA shell: sidebar, header, router
  views/
    login.js  dashboard.js  materials.js  suppliers.js
    products.js  deliveries.js  reports.js  notifications.js
```

## Chạy thử (local dev server)

Sử dụng một trong các lệnh sau (Phải chạy server vì Firebase không hoạt
động khi mở file trực tiếp bằng `file://`):

```bash
# Cách 1 - Python
python -m http.server 8080

# Cách 2 - PowerShell + .NET (không cần cài gì)
#   nhấn đúp run_web_server.ps1

# Cách 3 - Node
npx serve .
```

Mở trình duyệt: `http://localhost:8080`

## Tài khoản đăng nhập thử

| Tên đăng nhập | Mật khẩu | Vai trò   |
|---------------|----------|-----------|
| owner         | 123      | Chủ (xem giá) |
| ketoan1       | 123      | Kế toán   |
| ketoan2       | 123      | Kế toán   |
| user1         | 123      | User      |
| user2         | 123      | User      |

## Firebase

- Project: `qlvt-4d1fc`
- Collections: `materials`, `products`, `suppliers`, `deliveries`, `notifications`
- Giữ nguyên tên field để tương thích dữ liệu cũ.

