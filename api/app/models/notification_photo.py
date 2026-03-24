from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.models.user import Base 

class NotificationPhoto(Base):
    """
    **Bildirim Fotoğrafları Modeli**
    
    Bildirimlere eklenen kanıt fotoğraflarını ve bunların depolama bilgilerini yönetir.
    
    - **Hibrit Depolama:** Yapı hem yerel (local storage) hem de bulut (S3) 
      depolama sistemlerine uyumludur.
    - **Kısıtlamalar:** Uygulama seviyesinde max 5MB, JPEG/PNG ve bildirim başına 
      max 5 fotoğraf sınırı desteklenir.
    - **İlişki:** N Photo <-> 1 Notification (Bire-Çok).
    """
    __tablename__ = 'notification_photos'

    id = Column(Integer, primary_key=True, autoincrement=True)

    # CASCADE: Bildirim silindiğinde fotoğraf kayıtları da temizlenir.
    notification_id = Column(Integer, ForeignKey('notifications.id', ondelete='CASCADE'), nullable=False)

    # Depolama Bilgileri
    s3_key = Column(String(500), nullable=False)   # Dosya yolu (Örn: uploads/abc.jpg)
    s3_url = Column(String(1000), nullable=False)  # Tam erişim URL'i
    
    # Teknik Metadata
    file_size_bytes = Column(Integer, nullable=False)
    mime_type = Column(String(50), nullable=False) # image/jpeg, image/png vb.
    
    # UI tarafındaki sıralama (1, 2, 3...)
    display_order = Column(Integer, nullable=False)
    
    uploaded_at = Column(DateTime, nullable=False, server_default=func.now())

    # SQLAlchemy İlişkisi
    notification = relationship(
        "Notification",
        back_populates="notification_photos"
    )