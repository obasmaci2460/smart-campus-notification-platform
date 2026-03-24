from sqlalchemy import Integer, Column, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.models.user import Base 

class AdminNote(Base):
    """
    Bildirimler üzerine yöneticilerin (Admin) düştüğü dahili notları temsil eder.
    Bu tablo, kampüs sorunlarının çözüm sürecindeki iletişim trafiğini kayıt altında tutar.
    """
    __tablename__ = 'admin_notes'

    id = Column(Integer, primary_key=True, autoincrement=True)
    
    # Cascade: Bildirim silindiğinde notları da temizlenir.
    notification_id = Column(Integer, ForeignKey('notifications.id', ondelete='CASCADE'), nullable=False)
    admin_user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    note_content = Column(String(500), nullable=False)
    
    # Zaman Damgaları
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # İlişkiler (Relationships)
    notification = relationship(
        "Notification",
        back_populates="admin_notes"
    )

    admin_user = relationship(
        "User",
        back_populates="admin_notes"
    )

    @property
    def admin_name(self) -> str:
        """
        Notu yazan yöneticinin adını ve soyadını birleştirerek döndürür.
        Frontend tarafında kolay serileştirme sağlar.
        """
        if self.admin_user:
            return f"{self.admin_user.first_name} {self.admin_user.last_name}"
        return "Bilinmeyen Yönetici"