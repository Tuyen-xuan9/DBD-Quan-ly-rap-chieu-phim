PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS PHIM (
    MaPhim          INTEGER PRIMARY KEY AUTOINCREMENT,
    TenPhim         TEXT    NOT NULL,
    TheLoai         TEXT,
    ThoiLuong       INTEGER CHECK (ThoiLuong > 0),
    DaoDien         TEXT,
    NgayKhoiChieu   TEXT,
    NuocSanXuat     TEXT,
    XepHang         TEXT    CHECK (XepHang IN ('P', 'C13', 'C16', 'C18')),
    LinkAnh         TEXT
);

-- Thêm dữ liệu mẫu (INSERT)
INSERT OR IGNORE INTO PHIM (TenPhim, TheLoai, ThoiLuong, DaoDien, NgayKhoiChieu, NuocSanXuat, XepHang, LinkAnh) VALUES
('Avengers: Endgame', 'Hanh dong', 181, 'Anthony Russo', '2019-04-26', 'USA', 'C13', 'https://media.themoviedb.org/t/p/w600_and_h900_face/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg'),
('Inception', 'Khoa hoc vien tuong', 148, 'Christopher Nolan', '2010-07-16', 'USA', 'C13', 'https://media.themoviedb.org/t/p/w600_and_h900_face/xlaY2zyzMfkhk0HSC5VUwzoZPU1.jpg'),
('Lat Mat 7', 'Gia dinh', 138, 'Ly Hai', '2024-04-26', 'VN', 'C13', 'https://media.themoviedb.org/t/p/w600_and_h900_face/aSPg7viRKZUp6py0VLVTv6mo3GN.jpg'),
('Doraemon: Nobita va Vung Dat Ly Tuong', 'Hoat hinh', 107, 'Doyama Takumi', '2023-05-26', 'Nhat Ban', 'P', 'https://media.themoviedb.org/t/p/w600_and_h900_face/uux6M8z3hxLDkq8LXSzq8528mrq.jpg'),
('Joker: Folie a Deux', 'Tam ly', 138, 'Todd Phillips', '2024-10-04', 'USA', 'C18', 'https://media.themoviedb.org/t/p/w600_and_h900_face/aciP8Km0waTLXEYf5ybFK5CSUxl.jpg');

CREATE TABLE IF NOT EXISTS RAP_CHIEU (
    MaRap   INTEGER PRIMARY KEY AUTOINCREMENT,
    TenRap  TEXT    NOT NULL,
    DiaChi  TEXT,
    SoDT    TEXT,
    Email   TEXT    UNIQUE
);

CREATE TABLE IF NOT EXISTS PHONG_CHIEU (
    MaPhong     INTEGER PRIMARY KEY AUTOINCREMENT,
    MaRap       INTEGER NOT NULL,
    TenPhong    TEXT    NOT NULL,
    SoGheTong   INTEGER CHECK (SoGheTong > 0),
    LoaiPhong   TEXT    DEFAULT '2D'
                        CHECK (LoaiPhong IN ('2D', '3D', 'IMAX')),
    UNIQUE (MaRap, TenPhong),
    FOREIGN KEY (MaRap) REFERENCES RAP_CHIEU(MaRap) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS GHE (
    MaGhe       INTEGER PRIMARY KEY AUTOINCREMENT,
    MaPhong     INTEGER NOT NULL,
    SoGhe       TEXT    NOT NULL,
    LoaiGhe     TEXT    DEFAULT 'Thuong' CHECK (LoaiGhe IN ('Thuong', 'VIP')),
    TrangThai   TEXT    DEFAULT 'Trong'  CHECK (TrangThai IN ('Trong', 'Da Dat')),
    UNIQUE (MaPhong, SoGhe),
    FOREIGN KEY (MaPhong) REFERENCES PHONG_CHIEU(MaPhong) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS KHACH_HANG (
    MaKH        INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen       TEXT    NOT NULL,
    NgaySinh    TEXT,
    Email       TEXT    UNIQUE,
    SoDT        TEXT    NOT NULL,
    DiemTichLuy INTEGER DEFAULT 0 CHECK (DiemTichLuy >= 0)
);

CREATE TABLE IF NOT EXISTS NHAN_VIEN (
    MaNV        INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen       TEXT    NOT NULL,
    ChucVu      TEXT,
    Email       TEXT    UNIQUE,
    SoDT        TEXT,
    NgayVaoLam  TEXT    DEFAULT (DATE('now'))
);

CREATE TABLE IF NOT EXISTS SUAT_CHIEU (
    MaSuat      INTEGER PRIMARY KEY AUTOINCREMENT,
    MaPhim      INTEGER NOT NULL,
    MaPhong     INTEGER NOT NULL,
    NgayChieu   TEXT    NOT NULL,
    GioChieu    TEXT    NOT NULL,
    GiaVe       REAL    NOT NULL CHECK (GiaVe > 0),
    TrangThai   TEXT    DEFAULT 'Sap chieu'
                        CHECK (TrangThai IN ('Sap chieu', 'Dang chieu', 'Da chieu')),
    UNIQUE (MaPhong, NgayChieu, GioChieu),
    FOREIGN KEY (MaPhim)  REFERENCES PHIM(MaPhim)         ON DELETE RESTRICT,
    FOREIGN KEY (MaPhong) REFERENCES PHONG_CHIEU(MaPhong) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS VE (
    MaVe        INTEGER PRIMARY KEY AUTOINCREMENT,
    MaSuat      INTEGER NOT NULL,
    MaGhe       INTEGER NOT NULL,
    MaKH        INTEGER NOT NULL,
    NgayMua     TEXT    DEFAULT (DATETIME('now')),
    GiaVe       REAL    NOT NULL CHECK (GiaVe > 0),
    TrangThai   TEXT    DEFAULT 'Da mua'
                        CHECK (TrangThai IN ('Da mua', 'Da huy', 'Da dung')),
    UNIQUE (MaSuat, MaGhe),
    FOREIGN KEY (MaSuat) REFERENCES SUAT_CHIEU(MaSuat) ON DELETE RESTRICT,
    FOREIGN KEY (MaGhe)  REFERENCES GHE(MaGhe)         ON DELETE RESTRICT,
    FOREIGN KEY (MaKH)   REFERENCES KHACH_HANG(MaKH)   ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS PHAN_CONG (
    MaNV    INTEGER NOT NULL,
    MaSuat  INTEGER NOT NULL,
    PRIMARY KEY (MaNV, MaSuat),
    FOREIGN KEY (MaNV)   REFERENCES NHAN_VIEN(MaNV)    ON DELETE CASCADE,
    FOREIGN KEY (MaSuat) REFERENCES SUAT_CHIEU(MaSuat) ON DELETE CASCADE
);


-- Sample Data
INSERT OR IGNORE INTO RAP_CHIEU (TenRap, DiaChi, SoDT, Email) VALUES
('CGV Vincom Center',       '72 Le Thanh Ton, Q1, TP.HCM', '0286 2728 898', 'cgvvincom@cgv.vn'),
('Lotte Cinema Cantavil',   '28 Han Thuyen, Q1, TP.HCM',   '0286 2728 899', 'lottecantavil@lotte.vn'),
('Galaxy Cinema Nguyen Du', '116 Nguyen Du, Q1, TP.HCM',   '0286 2728 900', 'galaxynd@galaxy.vn');

INSERT OR IGNORE INTO PHONG_CHIEU (MaRap, TenPhong, SoGheTong, LoaiPhong) VALUES
(1,'Phong 1',150,'2D'),(1,'Phong 2',120,'3D'),(1,'Phong 3',80,'IMAX'),
(2,'Phong A',130,'2D'),(2,'Phong B',100,'3D'),
(3,'Phong X',140,'2D');

INSERT OR IGNORE INTO GHE (MaPhong, SoGhe, LoaiGhe, TrangThai) VALUES
(1,'A1','Thuong','Trong'),(1,'A2','Thuong','Trong'),(1,'A3','Thuong','Da Dat'),
(1,'B1','VIP','Trong'),(1,'B2','VIP','Da Dat'),
(2,'A1','Thuong','Trong'),(2,'A2','Thuong','Trong'),(2,'B1','VIP','Trong'),
(3,'A1','VIP','Trong'),(3,'A2','VIP','Trong');

INSERT OR IGNORE INTO KHACH_HANG (HoTen, NgaySinh, Email, SoDT, DiemTichLuy) VALUES
('Nguyen Thi Xuan Tuyen','2003-05-15','tuyen@gmail.com',    '0901234567',120),
('Tran Van An',          '2000-08-20','an.tran@gmail.com',  '0912345678', 50),
('Le Thi Bich',          '1995-03-10','bich.le@yahoo.com',  '0923456789',200),
('Pham Minh Tuan',       '1998-12-01','tuan.pm@gmail.com',  '0934567890', 80),
('Hoang Thi Mai',        '2001-07-25','mai.ht@hotmail.com', '0945678901',  0);

INSERT OR IGNORE INTO NHAN_VIEN (HoTen, ChucVu, Email, SoDT, NgayVaoLam) VALUES
('Nguyen Van Binh','Quan ly','binh.nv@cgv.vn','0901111111','2020-01-15'),
('Tran Thi Lan',   'Ban ve', 'lan.tt@cgv.vn', '0902222222','2021-06-01'),
('Le Van Hung',    'Kiem ve','hung.lv@cgv.vn','0903333333','2022-03-10'),
('Pham Thi Thu',   'Ban ve', 'thu.pt@cgv.vn', '0904444444','2023-01-20');

INSERT OR IGNORE INTO SUAT_CHIEU (MaPhim, MaPhong, NgayChieu, GioChieu, GiaVe, TrangThai) VALUES
(1,1,'2025-06-01','10:00',90000, 'Da chieu'),
(1,2,'2025-06-01','13:00',110000,'Da chieu'),
(2,3,'2025-06-02','15:00',150000,'Da chieu'),
(3,4,'2025-06-05','19:00',85000, 'Da chieu'),
(4,1,'2025-06-10','09:00',80000, 'Da chieu'),
(5,2,'2025-06-15','20:00',120000,'Sap chieu'),
(1,5,'2025-07-01','18:00',95000, 'Sap chieu');

INSERT OR IGNORE INTO VE (MaSuat, MaGhe, MaKH, GiaVe, TrangThai) VALUES
(1,1,1,90000, 'Da dung'),(1,2,2,90000, 'Da dung'),
(2,6,3,110000,'Da dung'),(3,9,1,150000,'Da dung'),
(4,4,4,85000, 'Da huy'), (5,1,5,80000, 'Da dung'),
(6,10,2,120000,'Da mua');

INSERT OR IGNORE INTO PHAN_CONG (MaNV, MaSuat) VALUES
(1,1),(2,1),(3,2),(2,3),(4,4),(3,5),(1,6),(4,7);

