from sqlalchemy import Column, Integer, String, Boolean
from app.core.database import Base
from sqlalchemy.orm import relationship

class Status(Base):
    """
    **Bildirim Durumları (Workflow) Modeli**
    
    Bildirimlerin yaşam döngüsündeki aşamaları (Beklemede, İnceleniyor, Çözüldü vb.) temsil eder.
    
    - **Dinamik UI:** 'color_hex' alanı sayesinde Flutter tarafındaki durum etiketlerinin 
      renkleri veritabanından merkezi olarak kontrol edilir.
    - **Süreç Yönetimi:** 'display_name' kullanıcıya dostane bir metin sunarken, 
      'name' alanı backend tarafında mantıksal kontroller için sabit (slug) olarak kullanılır.
    """
    __tablename__ = 'statuses'

    # Birincil anahtar (ID: 1-Beklemede, 2-İnceleniyor, 3-Çözüldü, 4-Reddedildi gibi)
    id = Column(Integer, primary_key=True)
    
    # Sistem tarafında kullanılan benzersiz teknik isim (Örn: 'pending')
    name = Column(String(15), nullable=False, unique=True)
    
    # Kullanıcıya arayüzde gösterilecek isim (Örn: 'İnceleme Altında')
    display_name = Column(String(30), nullable=False)
    
    # Duruma özgü hex renk kodu (Örn: #FF9800)
    color_hex = Column(String(7), nullable=True)
    
    # Durumun aktiflik kontrolü
    is_active = Column(Boolean, nullable=False, default=True)

    # İlişki: Bu durumda olan tüm bildirimlere erişim sağlar.
    notifications = relationship(
        "Notification",
        back_populates="status"
    )