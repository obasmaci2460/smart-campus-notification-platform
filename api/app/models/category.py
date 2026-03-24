from sqlalchemy import Column, Integer, String, Boolean
from app.core.database import Base
from sqlalchemy.orm import relationship

class Category(Base):
    """
    Bildirimlerin sınıflandırıldığı kategorileri temsil eder.
    
    Bu model, Flutter tarafındaki UI bileşenlerinin (renk, ikon, isim) 
    dinamik olarak veritabanından yönetilmesine olanak tanır.
    """
    __tablename__ = 'categories'

    id = Column(Integer, primary_key=True)
    
    # Sistem tarafında kullanılan benzersiz isim (Örn: 'security')
    name = Column(String(20), nullable=False, unique=True)
    
    # Kullanıcıya arayüzde gösterilecek isim (Örn: 'Güvenlik Birimi')
    display_name = Column(String(50), nullable=False)
    
    # UI tarafında kullanılacak ikon adı ve hex renk kodu
    icon = Column(String(50), nullable=True)
    color_hex = Column(String(7), nullable=True) # Örn: #FF0000
    
    is_active = Column(Boolean, nullable=False, default=True)

    # Bir kategoriye ait birden fazla bildirim olabilir.
    notifications = relationship(
        "Notification",
        back_populates="category"
    )