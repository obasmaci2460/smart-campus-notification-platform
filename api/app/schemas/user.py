from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class UserProfileResponse(BaseModel):
    """
    **Kullanıcı Profil Yanıt Şeması**
    Kullanıcının kendi bilgilerini veya başkalarının profilini (izin dahilinde) 
    görüntülemek için kullanılan kapsamlı yapı.
    """
    id: int
    email: str
    first_name: str
    last_name: str
    phone: Optional[str] = None
    department_id: int
    department_name: str = Field(..., description="ID yerine okunabilir departman adı (Örn: Bilgisayar Mühendisliği)")
    role: str = Field(..., description="Kullanıcı yetki rolü (user/admin)")
    created_at: datetime

    class Config:
        from_attributes = True

# --- Bildirim Tercihleri Şemaları ---

class NotificationPreferencesResponse(BaseModel):
    """
    **Bildirim Tercihleri Yanıt Şeması**
    Kullanıcının hangi kategorilerdeki duyurulardan anlık bildirim 
    almak istediğini gösteren mevcut ayarlar.
    """
    notify_security: bool = Field(..., description="Güvenlik olayları bildirimi")
    notify_maintenance: bool = Field(..., description="Teknik bakım ve onarım bildirimleri")
    notify_cleaning: bool = Field(..., description="Temizlik ve hijyen bildirimleri")
    notify_infrastructure: bool = Field(..., description="Altyapı ve yol çalışması bildirimleri")
    notify_other: bool = Field(..., description="Genel kampüs duyuruları")

class NotificationPreferencesUpdate(BaseModel):
    """
    **Bildirim Tercihleri Güncelleme Şeması**
    Kullanıcının sadece değiştirmek istediği tercihleri göndermesine olanak tanır.
    """
    notify_security: Optional[bool] = None
    notify_maintenance: Optional[bool] = None
    notify_cleaning: Optional[bool] = None
    notify_infrastructure: Optional[bool] = None
    notify_other: Optional[bool] = None

# --- Profil Güncelleme Şemaları ---

class UserProfileUpdate(BaseModel):
    """
    **Profil Güncelleme Şeması**
    Kullanıcının ad, soyad, telefon veya departman gibi bilgilerini 
    güvenli bir şekilde güncellemesi için kullanılır.
    """
    first_name: Optional[str] = Field(None, min_length=2, max_length=50)
    last_name: Optional[str] = Field(None, min_length=2, max_length=50)
    phone: Optional[str] = Field(None, min_length=10, max_length=15, description="Uluslararası formatta telefon numarası")
    department_id: Optional[int] = Field(None, ge=1, le=20, description="Yeni departman ID'si")

class UserPasswordUpdate(BaseModel):
    """
    **Şifre Değiştirme Şeması**
    Güvenlik için hem mevcut şifreyi hem de yeni belirlenen şifreyi zorunlu tutar.
    """
    current_password: str = Field(..., min_length=1, description="Doğrulama için mevcut şifre")
    new_password: str = Field(..., min_length=6, description="Yeni belirlenecek güçlü şifre")