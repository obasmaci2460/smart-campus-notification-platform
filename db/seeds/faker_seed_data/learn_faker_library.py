import pyodbc
import bcrypt
import random
import os
from datetime import datetime, timedelta
from faker import Faker
from dotenv import load_dotenv # Yeni ekledik: pip install python-dotenv

# .env dosyasındaki verileri yükle
load_dotenv()

fake = Faker('tr_TR')

def get_connection():
    # Şifreyi ve bilgileri güvenli bir şekilde çekiyoruz
    conn_str = (
        f"Driver={{ODBC Driver 18 for SQL Server}};"
        f"Server={os.getenv('DB_SERVER')};"
        f"Database={os.getenv('DB_NAME')};"
        f"UID={os.getenv('DB_UID')};"
        f"PWD={os.getenv('DB_PASSWORD')};"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
        "Connection Timeout=30"
    )
    return pyodbc.connect(conn_str)

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt(12)).decode()

def random_date_between(days_back: int) -> datetime:
    return datetime.now() - timedelta(days=random.randint(0, days_back))

def random_location(lat, lng, radius_km) -> tuple:
    # 0.009 yaklaşık 1km'ye tekabül eder (Basit bir yaklaşım)
    return (lat + random.uniform(-radius_km * 0.009, radius_km * 0.009), 
            lng + random.uniform(-radius_km * 0.009, radius_km * 0.009))

def random_address():
    return random.choice(["A Blok", "B Blok", "C Blok", "Kütüphane", "Kantin", "Spor Salonu"])

def cleanup_data(conn):
    print("🧹 Veritabanı temizleniyor...")
    cursor = conn.cursor()
    tables = [
        "broadcast_messages", "user_sessions", "sos_usage_tracking",
        "status_history", "admin_notes", "notification_followers",
        "notification_photos", "notifications", "failed_login_attempts",
        "notification_preferences", "fcm_tokens", "refresh_tokens", "users"
    ]
    for tablo in tables:
        try:
            cursor.execute(f"DELETE FROM {tablo}")
            cursor.execute(f"DBCC CHECKIDENT ('{tablo}', RESEED, 0)")
        except:
            pass # Identity olmayan tablolarda hata vermemesi için
    conn.commit()
    print("✅ Temizlik tamamlandı.")

def seed_users(conn):
    print("👥 Kullanıcılar oluşturuluyor...")
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM departments WHERE is_active=1")
    departments = [r[0] for r in cursor.fetchall()]
    
    user_ids = []
    password = hash_password("Test123!")
    
    for i in range(100):
        role = "user"
        is_super = 0
        if i == 0:
            role, is_super = "super_admin", 1
        elif i < 8:
            role = "admin"

        f_name, l_name = fake.first_name(), fake.last_name()
        # Türkçe karakter temizliği
        email = f"{f_name.lower()}.{l_name.lower()}.{i}@kampus.edu.tr" \
                .replace('ş','s').replace('ı','i').replace('ğ','g') \
                .replace('ü','u').replace('ç','c').replace('ö','o')
        
        # Trigger olan tablolarda OUTPUT kullanımı için DECLARE + INTO yapısı:
        cursor.execute("""
            SET NOCOUNT ON;
            DECLARE @InsertedID TABLE (id BIGINT);

            INSERT INTO users (email, password_hash, first_name, last_name, department_id, role, is_super_admin)
            OUTPUT INSERTED.id INTO @InsertedID
            VALUES (?, ?, ?, ?, ?, ?, ?);

            SELECT id FROM @InsertedID;
        """, (email, password, f_name, l_name, random.choice(departments), role, is_super))
        
        res = cursor.fetchone()
        if res:
            user_ids.append(res[0])
    
    conn.commit()
    print(f"✅ {len(user_ids)} kullanıcı eklendi.")
    return user_ids

def seed_notifications(conn, user_ids):
    print("📍 Bildirimler (SOS dahil) ekleniyor...")
    cursor = conn.cursor()
    cursor.execute("SELECT id FROM categories WHERE is_active=1")
    categories = [r[0] for r in cursor.fetchall()]
    cursor.execute("SELECT id FROM statuses WHERE is_active=1")
    statuses = [r[0] for r in cursor.fetchall()]

    for i in range(120):
        is_sos = 1 if i < 8 else 0
        lat, lng = random_location(41.0082, 28.9784, 2)
        
        cursor.execute("""
            INSERT INTO notifications (user_id, category_id, status_id, title, description, location, address, is_sos, is_high_priority, created_at)
            VALUES (?, ?, ?, ?, ?, geography::STGeomFromText(?, 4326), ?, ?, ?, ?)
        """, (
            random.choice(user_ids),
            1 if is_sos else random.choice(categories),
            random.choice(statuses),
            "ACİL SOS 🚨" if is_sos else fake.sentence(),
            fake.text(200),
            f"POINT({lng} {lat})",
            random_address(),
            is_sos,
            1 if is_sos else random.choice([0, 1]),
            random_date_between(30)
        ))
    
    conn.commit()
    print("✅ 120 bildirim haritaya işlendi.")

def main():
    print("="*40)
    print("🚀 CAMPUS APP SEED SİSTEMİ ÇALIŞIYOR")
    print("="*40)
    conn = get_connection()
    cleanup_data(conn)
    u_ids = seed_users(conn)
    seed_notifications(conn, u_ids)
    conn.close()
    print("\n🎉 İşlem Başarıyla Tamamlandı!")

if __name__ == "__main__":
    main()