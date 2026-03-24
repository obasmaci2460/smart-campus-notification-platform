from sqlalchemy import Column, Integer, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.models.user import Base # Base sınıfının User modelinden geldiği varsayımıyla

class NotificationPreference(Base):
    """
    **Kullanıcı Bildirim Tercihleri Modeli**
    
    Kullanıcıların hangi kampüs olayları (Güvenlik, Teknik Bakım, Temizlik vb.) 
    hakkında bildirim almak istediğini yönetir.
    
    - **Otomasyon:** Veritabanı seviyesindeki Trigger sayesinde yeni bir 'User' 
      oluştuğunda bu kayıt varsayılan (True) değerlerle otomatik oluşturulur.
    - **İlişki:** User (1) <--> Preference (1) (Bire-Bir İlişki).
    - **Veri Bütünlüğü:** Kullanıcı silindiğinde (CASCADE) tercihleri de otomatik temizlenir.
    """

    __tablename__ = 'notification_preferences'

    id = Column(Integer, primary_key=True, autoincrement=True)
    
    # Her kullanıcının tek bir tercih seti olabilir.
    user_id = Column(
        Integer,
        ForeignKey('users.id', ondelete='CASCADE'),
        nullable=False,
        unique=True
    )
    
    # Kategori Bazlı Bildirim İzinleri
    notify_security = Column(Boolean, nullable=False, default=True)      # Güvenlik olayları
    notify_maintenance = Column(Boolean, nullable=False, default=True)   # Teknik bakımlar
    notify_cleaning = Column(Boolean, nullable=False, default=True)      # Temizlik talepleri
    notify_infrastructure = Column(Boolean, nullable=False, default=True)# Altyapı çalışmaları
    notify_other = Column(Boolean, nullable=False, default=True)          # Diğer duyurular
    
    # Zaman Takibi
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())

    # SQLAlchemy İlişkisi
    user = relationship(
        "User",
        back_populates="notification_preference"
    )