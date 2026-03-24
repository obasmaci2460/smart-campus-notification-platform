from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.sql import func
from geoalchemy2 import Geography
from sqlalchemy.orm import deferred, relationship   
from app.core.database import Base

class Notification(Base):
    """
    **Kampüs Bildirim Sistemi Ana Modeli**
    
    Bu model, sistemdeki tüm olayların (SOS, Arıza, Şikayet vb.) merkezi deposudur.
    
    - **Spatial (Konum):** GeoAlchemy2 kullanılarak koordinatlar mekansal veri tipinde tutulur.
    - **Performans:** Ağır konum verisi 'deferred' ile sadece ihtiyaç duyulduğunda yüklenir.
    - **Durum Takibi:** Bildirimin oluşturulma, güncellenme, çözülme ve silinme (Soft Delete) 
      zaman damgalarını barındırır.
    """
    __tablename__ = 'notifications'
    # MSSQL üzerinde performans ve uyumluluk için implicit_returning kapalı
    __table_args__ = {'implicit_returning': False} 

    id = Column(Integer, primary_key=True, index=True)
    
    # İlişkisel Anahtarlar
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    category_id = Column(Integer, ForeignKey('categories.id'), nullable=False)
    status_id = Column(Integer, ForeignKey('statuses.id'), nullable=False, default=1)

    title = Column(String(80), nullable=False)
    description = Column(String(500), nullable=False)

    # Konum verisi: Binary formatta olduğu için ertelenmiş (deferred) yükleme yapılır.
    location = deferred(Column(Geography(geometry_type='POINT', srid=4326), nullable=True))
    address = Column(String(300), nullable=False)

    # Öncelik ve Tip Bayrakları
    is_sos = Column(Boolean, nullable=False, default=False)
    is_high_priority = Column(Boolean, nullable=False, default=False)

    # Zaman Damgaları (Audit Log)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())
    resolved_at = Column(DateTime, nullable=True)
    deleted_at = Column(DateTime, nullable=True) # Soft Delete desteği

    # Çözüm Bilgisi
    resolved_by_user_id = Column(Integer, ForeignKey('users.id'), nullable=True)

    # --- İlişkiler (Relationships) ---
    # CASCADE: Bildirim silindiğinde tüm alt kayıtlar temizlenir.
    
    user = relationship("User", foreign_keys=[user_id], back_populates="notifications")
    category = relationship("Category", back_populates="notifications")
    status = relationship("Status", back_populates="notifications")
    followers = relationship("NotificationFollower", back_populates="notification", cascade="all, delete-orphan")
    admin_notes = relationship("AdminNote", back_populates="notification", cascade="all, delete-orphan")
    notification_photos = relationship("NotificationPhoto", back_populates="notification", cascade="all, delete-orphan")
    status_history = relationship("StatusHistory", back_populates="notification", cascade="all, delete-orphan")
    
    resolved_by_user = relationship(
        "User", 
        foreign_keys=[resolved_by_user_id], 
        back_populates="resolved_notifications"
    )