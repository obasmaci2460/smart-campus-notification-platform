from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class User(Base):
    """
    **Sistem Ana Kullanıcı Modeli**
    
    Tüm yetkilendirme, profil yönetimi ve kullanıcı ilişkilerinin merkezidir.
    
    - **Yetkilendirme:** Role tabanlı (admin/user) ve Super Admin kontrolü barındırır.
    - **İlişkiler:** Bildirimler, takipler, admin notları ve tercihlerle 
      tam entegre çalışır.
    - **Güvenlik:** 'is_active' ile hesap dondurma ve 'deleted_at' ile 
      Soft Delete desteği sunar.
    """
    __tablename__ = 'users'
    
    # Kimlik Bilgileri
    id = Column(Integer, primary_key=True)
    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(60), nullable=False) # Bcrypt hash için 60 karakter
    
    # Profil Bilgileri
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    phone = Column(String(20), nullable=True)
    department_id = Column(Integer, ForeignKey('departments.id'), nullable=True)

    # Yetkilendirme ve Durum
    role = Column(String(15), nullable=False, default="user") # 'admin' veya 'user'
    is_super_admin = Column(Boolean, nullable=False, default=False)
    is_active = Column(Boolean, nullable=False, default=True)
    
    # Zaman Damgaları (Audit Logs)
    created_at = Column(DateTime(), nullable=False, server_default=func.now())
    updated_at = Column(DateTime(), nullable=False, server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(), nullable=True)

    # --- İlişkiler (Relationships) ---

    # Kullanıcının oluşturduğu bildirimler
    notifications = relationship(
        "Notification",
        foreign_keys="Notification.user_id",
        back_populates="user",
        lazy="select"
    )

    # Takip edilen bildirimler (Many-to-Many köprüsü üzerinden)
    followed_notifications = relationship(
        "NotificationFollower",
        back_populates="user",
        lazy="select"
    )

    # Eğer admin ise, yazdığı dahili notlar
    admin_notes = relationship(
        "AdminNote",
        back_populates="admin_user",
        lazy="select"
    )

    # Bağlı olduğu akademik/idari departman
    department = relationship(
        "Department",
        back_populates="users"
    )

    # Çözüme kavuşturduğu bildirimler (Admin için)
    resolved_notifications = relationship(
        "Notification",
        foreign_keys="Notification.resolved_by_user_id",
        back_populates="resolved_by_user"
    )

    # Yaptığı durum değişikliklerinin geçmişi
    status_changes = relationship(
        "StatusHistory",
        foreign_keys="StatusHistory.changed_by_user_id",
        back_populates="changed_by_user"
    )

    # Kişiselleştirilmiş bildirim tercihleri (Bire-bir ilişki)
    notification_preference = relationship(
        "NotificationPreference",
        back_populates="user",
        uselist=False 
    )