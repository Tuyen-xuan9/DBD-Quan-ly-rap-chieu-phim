# Hệ Thống Quản Lý Rạp Chiếu Phim

Một ứng dụng web nhỏ gọn giúp quản lý rạp chiếu phim, được xây dựng bằng Python, Flask và SQLite 3. Dự án này phù hợp cho việc học tập, thực hành thao tác với cơ sở dữ liệu và xây dựng ứng dụng web cơ bản.

---

## 🛠️ Công Nghệ Sử Dụng

| Thành phần | Công nghệ / Công cụ |
| :--- | :--- |
| **Backend** | Python, Flask Framework |
| **Database** | SQLite 3 |
| **Frontend** | HTML5, CSS3, Jinja2 Template Engine |
| **Tools** | VS Code, Draw.io (Thiết kế sơ đồ ERD) |

---

## 📂 Cấu Trúc Thư Mục

```text
Quan-ly-rap-chieu-phim-DBD/
├── templates/          # Giao diện HTML (Jinja2 templates)
├── app.py              # File chạy chính, xử lý Logic Backend & Routes
├── database.py         # Cấu hình kết nối và các hàm thao tác với SQLite
├── schema.sql          # Script SQL khởi tạo cấu trúc các bảng Database
├── cinema.db           # File Database SQLite (tự động tạo sau khi chạy)
└── README.md           # Tài liệu hướng dẫn sử dụng

## Hướng dẫn chạy
- Tải dự án về 
### Yêu cầu
- Đảm bảo bạn đã cài đặt Python 3.x.
  
```Cài đặt Flask:
pip install flask
```
## Khởi chạy ứng dụng
```
python app.py
```
- Truy cập: Mở trình duyệt và nhập địa chỉ *http://127.0.0.1:5000*
