from sqlalchemy import Column, Integer, DateTime, ForeignKey
from app.models.user import Base
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

class NotificationFollower(Base):
    """
    **Bildirim Takip Sistemi (Köprü Tablo)**
    
    Kullanıcılar ile bildirimler arasındaki 'Takip Etme' ilişkisini yönetir.
    Bu yapı sayesinde kullanıcılar ilgilendikleri olaylar hakkında güncel 
    bilgi alabilirler.
    
    - **İlişki:** User (1) <-> Notification (N) arasındaki Many-to-Many köprüsüdür.
    - **Otomatik Silme:** İlgili bildirim silindiğinde takip kayıtları da CASCADE ile temizlenir.
    """
    __tablename__ = 'notification_followers'

    id = Column(Integer, primary_key=True, autoincrement=True)
    
    # Takip edilen bildirimin referansı
    notification_id = Column(Integer, ForeignKey('notifications.id', ondelete='CASCADE'), nullable=False)
    
    # Takip eden kullanıcının referansı
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Takip işleminin gerçekleştiği zaman
    followed_at = Column(DateTime, server_default=func.now(), nullable=False)

    # SQLAlchemy İlişkileri
    notification = relationship(
        "Notification",
        back_populates="followers"
    )
    
    user = relationship(
        "User",
        back_populates="followed_notifications"
    )