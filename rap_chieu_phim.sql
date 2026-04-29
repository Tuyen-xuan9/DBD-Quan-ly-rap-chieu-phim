-- 1. Bảng PHIM
CREATE TABLE PHIM (
    MaPhim      SERIAL PRIMARY KEY,
    TenPhim     VARCHAR(200) NOT NULL,
    TheLoai     VARCHAR(100),
    ThoiLuong   INT          CHECK (ThoiLuong > 0),
    DaoDien     VARCHAR(100),
    NgayKhoiChieu DATE,
    NuocSanXuat VARCHAR(100),
    XepHang     VARCHAR(10)  CHECK (XepHang IN ('P', 'C13', 'C16', 'C18'))
);

-- 2. Bảng RẠP CHIẾU
CREATE TABLE RAP_CHIEU (
    MaRap   SERIAL PRIMARY KEY,
    TenRap  VARCHAR(150) NOT NULL,
    DiaChi  VARCHAR(255),
    SoDT    VARCHAR(15),
    Email   VARCHAR(100) UNIQUE
);

-- 3. Bảng PHÒNG CHIẾU
CREATE TABLE PHONG_CHIEU (
    MaPhong    SERIAL PRIMARY KEY,
    MaRap      INT         NOT NULL,
    TenPhong   VARCHAR(50) NOT NULL,
    SoGheTong  INT         CHECK (SoGheTong > 0),
    LoaiPhong  VARCHAR(10) CHECK (LoaiPhong IN ('2D', '3D', 'IMAX'))
               DEFAULT '2D',
    -- Mỗi phòng trong cùng một rạp phải có tên khác nhau
    UNIQUE (MaRap, TenPhong),
    FOREIGN KEY (MaRap) REFERENCES RAP_CHIEU(MaRap)
        ON DELETE CASCADE
);

-- 4. Bảng GHẾ
CREATE TABLE GHE (
    MaGhe      SERIAL PRIMARY KEY,
    MaPhong    INT         NOT NULL,
    SoGhe      VARCHAR(10) NOT NULL,
    LoaiGhe    VARCHAR(10) CHECK (LoaiGhe IN ('Thuong', 'VIP'))
               DEFAULT 'Thuong',
    TrangThai  VARCHAR(20) CHECK (TrangThai IN ('Trong', 'Da Dat'))
               DEFAULT 'Trong',
    -- Mỗi ghế trong cùng một phòng phải có số hiệu khác nhau
    UNIQUE (MaPhong, SoGhe),
    FOREIGN KEY (MaPhong) REFERENCES PHONG_CHIEU(MaPhong)
        ON DELETE CASCADE
);

-- 5. Bảng KHÁCH HÀNG
CREATE TABLE KHACH_HANG (
    MaKH        SERIAL PRIMARY KEY,
    HoTen       VARCHAR(100) NOT NULL,
    NgaySinh    DATE,
    Email       VARCHAR(100) UNIQUE,
    SoDT        VARCHAR(15)  NOT NULL,
    DiemTichLuy INT          DEFAULT 0 CHECK (DiemTichLuy >= 0)
);

-- 6. Bảng NHÂN VIÊN
CREATE TABLE NHAN_VIEN (
    MaNV       SERIAL PRIMARY KEY,
    HoTen      VARCHAR(100) NOT NULL,
    ChucVu     VARCHAR(50),
    Email      VARCHAR(100) UNIQUE,
    SoDT       VARCHAR(15),
    NgayVaoLam DATE         DEFAULT CURRENT_DATE
);

-- 7. Bảng SUẤT CHIẾU
CREATE TABLE SUAT_CHIEU (
    MaSuat    SERIAL PRIMARY KEY,
    MaPhim    INT           NOT NULL,
    MaPhong   INT           NOT NULL,
    NgayChieu DATE          NOT NULL,
    GioChieu  TIME          NOT NULL,
    GiaVe     NUMERIC(10,2) NOT NULL CHECK (GiaVe > 0),
    TrangThai VARCHAR(20)   CHECK (TrangThai IN ('Sap chieu', 'Dang chieu', 'Da chieu'))
              DEFAULT 'Sap chieu',
    -- một phòng không thể chiếu 2 suất cùng lúc
    UNIQUE (MaPhong, NgayChieu, GioChieu),
    FOREIGN KEY (MaPhim) REFERENCES PHIM(MaPhim)
        ON DELETE RESTRICT,
    FOREIGN KEY (MaPhong) REFERENCES PHONG_CHIEU(MaPhong)
        ON DELETE RESTRICT
);

-- 8. Bảng VÉ
CREATE TABLE VE (
    MaVe      SERIAL PRIMARY KEY,
    MaSuat    INT           NOT NULL,
    MaGhe     INT           NOT NULL,
    MaKH      INT           NOT NULL,
    NgayMua   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    GiaVe     NUMERIC(10,2) NOT NULL CHECK (GiaVe > 0),
    TrangThai VARCHAR(20)   CHECK (TrangThai IN ('Da mua', 'Da huy', 'Da dung'))
              DEFAULT 'Da mua',
    -- mỗi ghế chỉ được đặt 1 lần trong 1 suất chiếu
    UNIQUE (MaSuat, MaGhe),
    FOREIGN KEY (MaSuat) REFERENCES SUAT_CHIEU(MaSuat)
        ON DELETE RESTRICT,
    FOREIGN KEY (MaGhe) REFERENCES GHE(MaGhe)
        ON DELETE RESTRICT,
    FOREIGN KEY (MaKH) REFERENCES KHACH_HANG(MaKH)
        ON DELETE RESTRICT
);

-- 9. Bảng PHÂN CÔNG (Bảng trung gian N-N: NHÂN VIÊN - SUẤT CHIẾU)
CREATE TABLE PHAN_CONG (
    MaNV   INT NOT NULL,
    MaSuat INT NOT NULL,
    PRIMARY KEY (MaNV, MaSuat),
    FOREIGN KEY (MaNV) REFERENCES NHAN_VIEN(MaNV)
        ON DELETE CASCADE,
    FOREIGN KEY (MaSuat) REFERENCES SUAT_CHIEU(MaSuat)
        ON DELETE CASCADE
);
