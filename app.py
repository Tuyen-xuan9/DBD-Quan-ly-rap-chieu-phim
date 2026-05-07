from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
import database as db

app = Flask(__name__)
app.secret_key = 'cinema_secret_2025'


@app.before_request
def setup():
    db.init_db()


# ─────────────────────────────────────────────
# CUSTOMER ROUTES
# ─────────────────────────────────────────────

@app.route('/')
def index():
    search = request.args.get('q', '')
    genre  = request.args.get('theloai', '')
    rating = request.args.get('xepHang', '')

    sql = "SELECT * FROM PHIM WHERE 1=1"
    params = []
    if search:
        sql += " AND TenPhim LIKE ?"
        params.append(f'%{search}%')
    if genre:
        sql += " AND TheLoai = ?"
        params.append(genre)
    if rating:
        sql += " AND XepHang = ?"
        params.append(rating)
    sql += " ORDER BY MaPhim DESC"

    phims   = db.query(sql, params)
    genres  = db.query("SELECT DISTINCT TheLoai FROM PHIM ORDER BY TheLoai")
    return render_template('index.html', phims=phims, genres=genres,
                           search=search, selected_genre=genre, selected_rating=rating)


@app.route('/phim/<int:ma_phim>')
def movie_detail(ma_phim):
    phim = db.query("SELECT * FROM PHIM WHERE MaPhim=?", (ma_phim,), one=True)
    if not phim:
        flash('Không tìm thấy phim.', 'error')
        return redirect(url_for('index'))

    suats = db.query("""
        SELECT sc.*, pc.TenPhong, pc.LoaiPhong, r.TenRap
        FROM SUAT_CHIEU sc
        JOIN PHONG_CHIEU pc ON sc.MaPhong = pc.MaPhong
        JOIN RAP_CHIEU   r  ON pc.MaRap   = r.MaRap
        WHERE sc.MaPhim = ? AND sc.TrangThai IN ('Sap chieu','Dang chieu')
        ORDER BY sc.NgayChieu, sc.GioChieu
    """, (ma_phim,))
    return render_template('movie_detail.html', phim=phim, suats=suats)


@app.route('/dat-ve/<int:ma_suat>')
def booking(ma_suat):
    suat = db.query("""
        SELECT sc.*, p.TenPhim, p.ThoiLuong, p.XepHang,
               pc.TenPhong, pc.LoaiPhong, r.TenRap
        FROM SUAT_CHIEU sc
        JOIN PHIM        p  ON sc.MaPhim  = p.MaPhim
        JOIN PHONG_CHIEU pc ON sc.MaPhong = pc.MaPhong
        JOIN RAP_CHIEU   r  ON pc.MaRap   = r.MaRap
        WHERE sc.MaSuat = ?
    """, (ma_suat,), one=True)
    if not suat:
        flash('Suất chiếu không tồn tại.', 'error')
        return redirect(url_for('index'))

    ghes = db.query("""
        SELECT g.*,
               CASE WHEN v.MaVe IS NOT NULL THEN 1 ELSE 0 END as DaDat
        FROM GHE g
        LEFT JOIN VE v ON v.MaGhe = g.MaGhe AND v.MaSuat = ? AND v.TrangThai != 'Da huy'
        WHERE g.MaPhong = ?
        ORDER BY g.SoGhe
    """, (ma_suat, suat['MaPhong']))

    khach_hangs = db.query("SELECT * FROM KHACH_HANG ORDER BY HoTen")
    return render_template('booking.html', suat=suat, ghes=ghes, khach_hangs=khach_hangs)


@app.route('/dat-ve/xac-nhan', methods=['POST'])
def confirm_booking():
    ma_suat = request.form.get('ma_suat', type=int)
    ma_ghe  = request.form.get('ma_ghe',  type=int)
    ma_kh   = request.form.get('ma_kh',   type=int)

    suat = db.query("SELECT * FROM SUAT_CHIEU WHERE MaSuat=?", (ma_suat,), one=True)
    if not suat:
        return jsonify({'ok': False, 'msg': 'Suất chiếu không hợp lệ'})

    existing = db.query("SELECT * FROM VE WHERE MaSuat=? AND MaGhe=? AND TrangThai!='Da huy'",
                        (ma_suat, ma_ghe), one=True)
    if existing:
        return jsonify({'ok': False, 'msg': 'Ghế đã được đặt!'})

    db.execute("INSERT INTO VE (MaSuat, MaGhe, MaKH, GiaVe) VALUES (?,?,?,?)",
               (ma_suat, ma_ghe, ma_kh, suat['GiaVe']))
    db.execute("UPDATE KHACH_HANG SET DiemTichLuy = DiemTichLuy + 10 WHERE MaKH=?", (ma_kh,))
    return jsonify({'ok': True, 'msg': 'Đặt vé thành công! +10 điểm tích lũy'})


# ─────────────────────────────────────────────
# ADMIN ROUTES
# ─────────────────────────────────────────────

@app.route('/admin')
def admin_dashboard():
    stats = db.get_stats()
    recent_ves = db.query("""
        SELECT v.MaVe, kh.HoTen, p.TenPhim, sc.NgayChieu, sc.GioChieu,
               g.SoGhe, v.GiaVe, v.TrangThai, v.NgayMua
        FROM VE v
        JOIN KHACH_HANG  kh ON v.MaKH   = kh.MaKH
        JOIN SUAT_CHIEU  sc ON v.MaSuat = sc.MaSuat
        JOIN PHIM         p ON sc.MaPhim = p.MaPhim
        JOIN GHE          g ON v.MaGhe   = g.MaGhe
        ORDER BY v.NgayMua DESC LIMIT 10
    """)
    return render_template('admin_dashboard.html', stats=stats, recent_ves=recent_ves)


@app.route('/admin/phim')
def admin_movies():
    phims = db.query("SELECT * FROM PHIM ORDER BY MaPhim DESC")
    return render_template('admin_movies.html', phims=phims)


@app.route('/admin/phim/them', methods=['POST'])
def admin_add_movie():
    data = request.form
    try:
        db.execute("""INSERT INTO PHIM (TenPhim, TheLoai, ThoiLuong, DaoDien, NgayKhoiChieu, NuocSanXuat, XepHang, LinkAnh)
                      VALUES (?,?,?,?,?,?,?,?)""",
                   (data['TenPhim'], data['TheLoai'], data['ThoiLuong'],
                    data['DaoDien'], data['NgayKhoiChieu'], data['NuocSanXuat'], 
                    data['XepHang'], data['LinkAnh'])) # Thêm LinkAnh vào đây
        flash('Thêm phim thành công!', 'success')
    except Exception as e:
        flash(f'Lỗi: {str(e)}', 'error')
    return redirect(url_for('admin_movies'))


@app.route('/admin/phim/sua/<int:ma>', methods=['POST'])
def admin_edit_movie(ma):
    data = request.form
    db.execute("""UPDATE PHIM SET TenPhim=?, TheLoai=?, ThoiLuong=?, DaoDien=?,
                  NgayKhoiChieu=?, NuocSanXuat=?, XepHang=? WHERE MaPhim=?""",
               (data['TenPhim'], data['TheLoai'], data.get('ThoiLuong', type=int),
                data['DaoDien'], data['NgayKhoiChieu'], data['NuocSanXuat'],
                data['XepHang'], ma))
    flash('Cập nhật phim thành công!', 'success')
    return redirect(url_for('admin_movies'))


@app.route('/admin/phim/xoa/<int:ma>', methods=['POST'])
def admin_delete_movie(ma):
    try:
        db.execute("DELETE FROM PHIM WHERE MaPhim=?", (ma,))
        flash('Xóa phim thành công!', 'success')
    except Exception as e:
        flash(f'Không thể xóa: {str(e)}', 'error')
    return redirect(url_for('admin_movies'))


@app.route('/admin/suat-chieu')
def admin_showtimes():
    suats = db.query("""
        SELECT sc.*, p.TenPhim, pc.TenPhong, pc.LoaiPhong, r.TenRap,
               (SELECT COUNT(*) FROM VE v WHERE v.MaSuat=sc.MaSuat AND v.TrangThai!='Da huy') as SoVeDaBan
        FROM SUAT_CHIEU sc
        JOIN PHIM        p  ON sc.MaPhim  = p.MaPhim
        JOIN PHONG_CHIEU pc ON sc.MaPhong = pc.MaPhong
        JOIN RAP_CHIEU   r  ON pc.MaRap   = r.MaRap
        ORDER BY sc.NgayChieu DESC, sc.GioChieu
    """)
    phims  = db.query("SELECT MaPhim, TenPhim FROM PHIM ORDER BY TenPhim")
    phongs = db.query("""SELECT pc.MaPhong, pc.TenPhong, pc.LoaiPhong, r.TenRap
                         FROM PHONG_CHIEU pc JOIN RAP_CHIEU r ON pc.MaRap=r.MaRap""")
    return render_template('admin_showtimes.html', suats=suats, phims=phims, phongs=phongs)


@app.route('/admin/suat-chieu/them', methods=['POST'])
def admin_add_showtime():
    data = request.form
    try:
        db.execute("""INSERT INTO SUAT_CHIEU (MaPhim, MaPhong, NgayChieu, GioChieu, GiaVe, TrangThai)
                      VALUES (?,?,?,?,?,?)""",
                   (data['MaPhim'], data['MaPhong'], data['NgayChieu'],
                    data['GioChieu'], data['GiaVe'], data['TrangThai']))
        flash('Thêm suất chiếu thành công!', 'success')
    except Exception as e:
        flash(f'Lỗi: {str(e)}', 'error')
    return redirect(url_for('admin_showtimes'))


@app.route('/admin/suat-chieu/xoa/<int:ma>', methods=['POST'])
def admin_delete_showtime(ma):
    try:
        db.execute("DELETE FROM SUAT_CHIEU WHERE MaSuat=?", (ma,))
        flash('Xóa suất chiếu thành công!', 'success')
    except Exception as e:
        flash(f'Không thể xóa: {str(e)}', 'error')
    return redirect(url_for('admin_showtimes'))


@app.route('/admin/suat-chieu/doi-trang-thai/<int:ma>', methods=['POST'])
def toggle_showtime_status(ma):
    trang_thai = request.form.get('trang_thai')
    db.execute("UPDATE SUAT_CHIEU SET TrangThai=? WHERE MaSuat=?", (trang_thai, ma))
    return jsonify({'ok': True})


if __name__ == '__main__':
    db.init_db()
    app.run(debug=True, port=5000)