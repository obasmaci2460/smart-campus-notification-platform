from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from app.schemas.admin_note import AdminNoteResponse

class NotificationCreate(BaseModel):
    """Kampüs içinde yeni bir olay bildirimi oluşturma şeması"""
    category_id: int = Field(..., ge=1, le=5, description="Kategori ID (1-5 arası)")
    
class NotificationUpdate(BaseModel):
    """Mevcut bir bildirimin içeriğini güncelleme şeması"""
    title: Optional[str] = Field(None, min_length=3, max_length=80)
    description: Optional[str] = Field(None, min_length=5, max_length=500)

class NotificationStatusUpdate(BaseModel):
    """
    Bildirim durumunu güncelleme şeması.
    1: Açık (Yeni), 2: İnceleniyor, 3: Çözüldü, 4: Spam/İptal
    """
    status_id: int = Field(..., ge=1, le=4, description="Süreci yönetmek için yeni durum ID'si")

class LocationResponse(BaseModel):
    """Harita üzerinde kesin konum ve adres bilgisi"""
    latitude: float
    longitude: float
    address: Optional[str] = None

class NotificationDetailResponse(BaseModel):
    """
    **Bildirim Detay Şeması**
    Bir bildirimin tüm geçmişini, admin notlarını ve görsellerini içeren kapsamlı yanıt yapısı.
    """
    id: int
    user_id: int
    category_id: int
    category_name: str
    status_id: int
    status_name: str
    title: str
    description: str
    address: str
    is_sos: bool = Field(..., description="Acil durum çağrısı mı?")
    is_high_priority: bool = Field(..., description="Yüksek öncelikli olay mı?")
    created_at: datetime
    updated_at: datetime
    resolved_at: Optional[datetime] = None
    resolved_by_user_id: Optional[int] = None
    
    # İlişkili alt modeller
    admin_notes: List[AdminNoteResponse] = []
    photos: List[str] = Field([], description="Fotoğrafların erişim URL listesi")
    is_following: bool = Field(False, description="İsteği atan kullanıcı bu bildirimi takip ediyor mu?")
    
    # Konum verileri
    latitude: Optional[float] = None
    longitude: Optional[float] = None

    class Config:
        from_attributes = True

class ResolvedByUser(BaseModel):
    """Bildirimi çözen yöneticinin (admin) temel profil bilgileri"""
    id: int
    email: str
    first_name: str
    last_name: str

    class Config:
        from_attributes = True

class StatusUpdateResponse(BaseModel):
    """
    **Durum Güncelleme Yanıt Şeması** (Hatanın Çözümü Burada!)
    Durum değişikliği sonrası dönen onay ve çözüm bilgileri.
    """
    id: int
    status_id: int
    status_name: str
    resolved_at: Optional[datetime] = None
    resolved_by_user_id: Optional[int] = None
    resolved_by: Optional[ResolvedByUser] = None

    class Config:
        from_attributes = True

class SOSNotificationCreate(BaseModel):
    """Hızlı acil durum kaydı için gerekli GPS ve içerik verileri"""
    title: str = Field(..., min_length=3, max_length=200)
    description: str = Field(..., min_length=10, max_length=1000)
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    address: Optional[str] = Field(None, max_length=500)

class SOSNotificationResponse(BaseModel):
    """Acil durum oluşturulduktan sonra dönen özet yanıt"""
    id: int
    title: str
    description: str
    category_id: int
    status_id: int
    is_sos: bool
    is_high_priority: bool
    created_at: datetime
    
class NearbyNotificationItem(BaseModel):
    """Harita üzerinde listeleme için mesafe bilgisi içeren öge"""
    id: int
    title: str
    description: str
    category_id: int
    category_name: str
    status_id: int
    status_name: str
    latitude: float
    longitude: float
    distance_meters: float = Field(..., description="Kullanıcıya olan kuş uçuşu mesafe (metre)")
    is_sos: bool
    created_at: datetime

class NearbyNotificationsResponse(BaseModel):
    """Harita görünümü için belirli bir yarıçaptaki tüm olayların listesi"""
    notifications: List[NearbyNotificationItem]
    count: int
    center: dict
    radius_meters: int