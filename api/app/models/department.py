from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class Department(Base):
    """
    **Departman Modeli**
    
    Kampüs içindeki akademik veya idari birimleri temsil eder.
    
    - **İlişkiler:** Bire-Çok (One-to-Many) mantığıyla birden fazla 'User' (Kullanıcı) 
      bir departmana bağlı olabilir.
    - **Veri Bütünlüğü:** `is_active` bayrağı ile departmanların silinmeden pasifize 
      edilmesini sağlar (Soft Delete mantığına hazırlık).
    """

    __tablename__ = 'departments'

    id = Column(Integer, primary_key=True, autoincrement=True)
    
    # Departman adı (Örn: 'Bilgisayar Mühendisliği', 'Öğrenci İşleri')
    name = Column(String(100), nullable=False)
    
    is_active = Column(Boolean, nullable=False, default=True)
    
    # Veritabanı seviyesinde otomatik oluşturulma tarihi
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    # Ters İlişki (Back-populates 'User' modelindeki 'department' alanı ile eşleşir)
    users = relationship(
        "User",
        back_populates='department'
    )