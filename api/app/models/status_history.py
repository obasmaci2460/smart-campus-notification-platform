from sqlalchemy import Column, Integer, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base

class StatusHistory(Base):
    """
    **Durum Değişim Geçmişi (Audit Log) Modeli**
    
    Bildirimlerin yaşam döngüsü boyunca geçirdiği tüm durum değişikliklerini kayıt altında tutar.
    
    - **Süreç İzlenebilirliği:** Bir bildirimin hangi aşamalardan geçtiğini kronolojik olarak sunar.
    - **Sorumluluk Takibi:** Her değişikliği yapan 'User' (genellikle Admin) bilgisini saklar.
    - **Otomasyon:** Veritabanı seviyesindeki Trigger veya uygulama seviyesindeki 
      Logic ile durum değişimlerinde otomatik kayıt oluşturulur.
    """

    __tablename__ = 'status_history'

    # Birincil anahtar
    id = Column(Integer, primary_key=True, autoincrement=True)
    
    # Hangi bildirimin durumu değişti? (Bildirim silinirse geçmişi de CASCADE ile silinir)
    notification_id = Column(
        Integer,
        ForeignKey('notifications.id', ondelete='CASCADE'),
        nullable=False
    )
    
    # Eski durum (İlk oluşturulduğunda NULL olabilir)
    old_status_id = Column(Integer, ForeignKey('statuses.id'), nullable=True)

    # Yeni atanan durum
    new_status_id = Column(Integer, ForeignKey('statuses.id'), nullable=False)
    
    # Değişikliği yapan kullanıcı (Admin/Yönetici) referansı
    changed_by_user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    
    # Değişikliğin yapıldığı an (Veritabanı tarafında otomatik atanır)
    changed_at = Column(DateTime, nullable=False, server_default=func.now())

    # --- İlişkiler (Relationships) ---
    
    notification = relationship(
        "Notification",
        back_populates="status_history"
    )

    # Değişikliği yapan kullanıcı ilişkisi
    changed_by_user = relationship(
        "User",
        foreign_keys=[changed_by_user_id],
        back_populates="status_changes"
    )

    # Durum nesnelerine doğrudan erişim sağlayan ilişkiler
    old_status = relationship(
        "Status",
        foreign_keys=[old_status_id]
    )

    new_status = relationship(
        "Status",
        foreign_keys=[new_status_id]
    )