from pydantic import BaseModel, Field
from datetime import datetime
from typing import List

class FollowerResponse(BaseModel):
    """
    **Bildirim Takipçisi Detay Şeması**
    
    Bir bildirimi takip eden kullanıcının temel profil bilgilerini ve 
    takip başlangıç tarihini içerir. 
    """
    id: int = Field(..., description="Kullanıcının benzersiz ID'si")
    email: str = Field(..., description="Kullanıcının email adresi")
    first_name: str = Field(..., description="Kullanıcının adı")
    last_name: str = Field(..., description="Kullanıcının soyadı")
    followed_at: datetime = Field(..., description="Takip işleminin gerçekleştiği zaman damgası")

    class Config:
        # Veritabanı modelinden (SQLAlchemy) Pydantic'e veri aktarımını sağlar
        from_attributes = True

class FollowersListResponse(BaseModel):
    """
    **Takipçi Listesi Şeması**
    
    Belirli bir bildirim için tüm takipçileri ve toplam sayıyı 
    Flutter tarafına toplu olarak sunar.
    """
    total: int = Field(..., description="Bildirimi takip eden toplam kullanıcı sayısı")
    followers: List[FollowerResponse] = Field(..., description="Takipçi detaylarını içeren liste")