from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from app.core.database import Base

class FailedLoginAttempt(Base):
    """
    **Brute-Force Koruması ve Güvenlik İzleme Modeli**
    
    Bu tablo, sisteme yapılan hatalı giriş denemelerini kayıt altında tutar.
    
    - **Güvenlik Mantığı:** 24 saat içinde veya belirli bir periyotta yapılan 
      üst üste hatalı denemeleri (Örn: 5 deneme) tespit eder.
    - **Hesap Kilitleme:** `locked_until` kolonu ile kullanıcıyı geçici olarak 
      sistem dışı bırakır (Örn: 5 dakika).
    - **IP İzleme:** IPv4 ve IPv6 destekli IP takibi yaparak bot saldırılarını analiz eder.
    """

    __tablename__ = 'failed_login_attempts'

    id = Column(Integer, primary_key=True, autoincrement=True)
    
    # Hatalı giriş yapılan email adresi (Sistemde kayıtlı olsun ya da olmasın)
    email = Column(String(255), nullable=False)
    
    # Saldırının geldiği IP adresi (IPv6 uyumlu)
    ip_address = Column(String(45), nullable=True)
    
    # Deneme zamanı (Veritabanı seviyesinde otomatik)
    attempted_at = Column(DateTime, nullable=False, server_default=func.now())
    
    # Kilidin kalkacağı zaman (Null ise hesap kilitli değil demektir)
    locked_until = Column(DateTime, nullable=True)