import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), 'cinema.db')
SCHEMA_PATH = os.path.join(os.path.dirname(__file__), 'schema.sql')


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    if os.path.exists(DB_PATH):
        return
    with get_db() as conn:
        with open(SCHEMA_PATH, 'r', encoding='utf-8') as f:
            conn.executescript(f.read())
    print("✅ Database initialized.")


def query(sql, params=(), one=False):
    with get_db() as conn:
        cur = conn.execute(sql, params)
        result = cur.fetchone() if one else cur.fetchall()
    return result


def execute(sql, params=()):
    with get_db() as conn:
        cur = conn.execute(sql, params)
        conn.commit()
        return cur.lastrowid


def get_stats():
    stats = {}
    stats['total_phim']   = query("SELECT COUNT(*) as c FROM PHIM", one=True)['c']
    stats['total_kh']     = query("SELECT COUNT(*) as c FROM KHACH_HANG", one=True)['c']
    stats['total_nv']     = query("SELECT COUNT(*) as c FROM NHAN_VIEN", one=True)['c']
    stats['sap_chieu']    = query("SELECT COUNT(*) as c FROM SUAT_CHIEU WHERE TrangThai='Sap chieu'", one=True)['c']
    stats['dang_chieu']   = query("SELECT COUNT(*) as c FROM SUAT_CHIEU WHERE TrangThai='Dang chieu'", one=True)['c']
    stats['ve_da_ban']    = query("SELECT COUNT(*) as c FROM VE WHERE TrangThai IN ('Da mua','Da dung')", one=True)['c']
    row = query("SELECT SUM(GiaVe) as total FROM VE WHERE TrangThai IN ('Da mua','Da dung')", one=True)
    stats['doanh_thu']    = row['total'] or 0
    stats['ve_da_huy']    = query("SELECT COUNT(*) as c FROM VE WHERE TrangThai='Da huy'", one=True)['c']
    return stats