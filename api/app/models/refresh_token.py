from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey
from app.core.database import Base
from sqlalchemy.sql import func

class RefreshToken(Base):
    """
    **Güvenli Oturum Yönetimi (Refresh Token) Modeli**
    
    Kullanıcıların 'Beni Hatırla' özelliğini ve uzun süreli oturumlarını yönetir.
    Bu tablo, Access Token süresi dolduğunda kullanıcının tekrar giriş yapmadan 
    yeni bir session almasını sağlar.
    
    - **Güvenlik:** Token'lar veritabanında SHA-256 hash formatında saklanarak sızmalara karşı korunur.
    - **Rotasyon & İptal:** Logout işlemlerinde veya şüpheli durumlarda `is_revoked` bayrağı ile 
      oturum anında sonlandırılabilir.
    - **İlişki:** User (1) <--> RefreshToken (N) (Bir kullanıcının farklı cihazlarda 
      birden fazla oturumu olabilir).
    """
    __tablename__ = "refresh_tokens"

    # Birincil anahtar ve hızlı sorgulama için indeks
    id = Column(Integer, primary_key=True, index=True)
    
    # Oturumun sahibi olan kullanıcıya referans
    user_id = Column(Integer, ForeignKey('users.id'))
    
    # Token'ın SHA-256 hash'lenmiş hali. 
    # Düz metin (plain text) saklanmayarak veri tabanı güvenliği artırılmıştır.
    token_hash = Column(String(64), unique=True, nullable=False)
    
    # Token'ın geçerlilik süresi (Genellikle 7 veya 30 gün)
    expires_at = Column(DateTime(), nullable=False)
    
    # Güvenlik Kontrolleri: 
    # is_revoked: True ise token geçerli olsa bile sistemden reddedilir.
    is_revoked = Column(Boolean, nullable=False, default=False)
    revoked_at = Column(DateTime(), nullable=True) # İptal edilme zamanı (Logout zamanı)
    
    # Kayıt Zamanı: Veritabanı seviyesinde otomatik atanır.
    created_at = Column(DateTime(), nullable=False, server_default=func.now())