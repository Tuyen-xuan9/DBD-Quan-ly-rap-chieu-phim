# Hệ Thống Quản Lý Rạp Chiếu Phim

## Công nghệ sử dụng
- Database: SQLite 3
- Backend: Python, Flask Framework
- Frontend: HTML5, CSS3 (Modern Dark Theme), Jinja2
- Tools: Draw.io (ERD), VS Code, GitHub

## Cấu trúc thư mục
Quan-ly-rap-chieu-phim-DBD/
├── static/              # Chứa file CSS, hình ảnh UI
├── templates/           # Giao diện HTML 
├── app.py               # Xử lý Logic Backend
├── database.py          # Kết nối và thao tác SQLite
├── schema.sql           # Script khởi tạo cấu trúc DB
├── cinema.db            # File Database SQLite (tự động tạo)
└── README.md            # Tài liệu hướng dẫn

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

```bash
psql -U postgres -d rap_chieu_phim -f rap_chieu_phim.sql
```

Hoặc mở file `rap_chieu_phim.sql` trong **pgAdmin** → Query Tool → Execute.
