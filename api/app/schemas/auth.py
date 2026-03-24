from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from datetime import datetime

class UserRegister(BaseModel):
    """
    **Kullanıcı Kayıt Şeması**
    Yeni bir kullanıcı oluşturulurken gelen verileri doğrular. 
    İçerdiği validator'lar sayesinde veritabanına sadece geçerli verilerin gitmesini sağlar.
    """
    email: EmailStr = Field(..., description="Üniversite email adresi (.edu uzantılı zorunlu)")
    password: str = Field(..., min_length=8, max_length=50, description="Güçlü şifre politikasına uygun şifre")
    first_name: str = Field(..., min_length=1, max_length=50)
    last_name: str = Field(..., min_length=1, max_length=50)
    department_id: int = Field(..., gt=0, description="Bağlı olunan departman ID'si")
    phone: Optional[str] = Field(None, max_length=20)

    @validator('email')
    def email_must_be_edu(cls, v):
        """
        **İş Kuralı (Business Logic):** Sistemin kampüs dışı erişime kapalı olması için .edu kontrolü yapar.
        """
        if not ('.edu' in v.lower()):
            raise ValueError("Güvenlik gereği sadece .edu uzantılı üniversite mailleri kabul edilir.")
        return v.lower()

    @validator('password')
    def password_strength(cls, v): 
        """
        **Güvenlik Politikası:** Brute-force saldırılarına karşı şifre komplekslik kontrolü (Büyük/Küçük harf, Rakam, Özel Karakter).
        """
        if not any(c.isupper() for c in v):
            raise ValueError("Şifre en az 1 büyük harf içermelidir.")
        if not any(c.islower() for c in v):
            raise ValueError("Şifre en az 1 küçük harf içermelidir.")
        if not any(c.isdigit() for c in v):
            raise ValueError("Şifre en az 1 rakam içermelidir.")
        if not any(c in '!@#$%^&*' for c in v):
            raise ValueError("Şifre en az 1 özel karakter içermelidir (!@#$%^&*)")
        return v

class UserLogin(BaseModel):
    """
    **Giriş Şeması**
    Oturum açma isteği ile birlikte platform bilgisi ve bildirim (FCM) token'ını yakalar.
    """
    email: EmailStr
    password: str
    platform: str = Field(..., pattern="^(ios|android)$", description="İsteğin geldiği mobil işletim sistemi")
    fcm_token: Optional[str] = Field(None, description="Firebase Cloud Messaging token'ı")

class TokenResponse(BaseModel):
    """
    **JWT Yanıt Şeması**
    Başarılı giriş sonrası dönen Access ve Refresh token bilgilerini içerir.
    """
    access_token: str
    refresh_token: str
    token_type: str = "bearer"    
    expires_in: int = 86400 # Varsayılan: 24 Saat (saniye cinsinden)

class TokenRefresh(BaseModel):
    """Refresh token ile yeni access token alma isteği şeması"""
    refresh_token: str = Field(..., description="Geçerli ve süresi dolmamış refresh token")    

class UserResponse(BaseModel):
    """
    **Genel Kullanıcı Yanıt Şeması**
    Hassas verileri (şifre hash gibi) gizleyerek kullanıcı bilgisini döner.
    """
    id: int
    email: str
    first_name: str
    last_name: str
    role: str
    is_super_admin: bool
    department_id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True # SQLAlchemy modellerinden Pydantic'e otomatik dönüşüm sağlar

class AuthSuccessResponse(BaseModel):
    """Kayıt veya Giriş sonrası dönen birleşik veri yapısı (User + Tokens)"""
    user: dict 
    tokens: TokenResponse

class UserProfileResponse(BaseModel):
    """Profil detaylarını (ME endpoint) dönen optimize edilmiş şema"""
    id: int
    email: str
    first_name: str
    last_name: str
    role: str
    is_super_admin: bool
    is_active: bool
    department_id: int
    phone: Optional[str] = None

    class Config:
        from_attributes = True