import bcrypt
from datetime import datetime, timedelta
from jose import JWTError, jwt
from app.core.config import settings
from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user import User
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

# --- ŞİFRELEME (HASHING) İŞLEMLERİ ---

def hash_password(password: str) -> str:
    """
    Şifreyi Bcrypt algoritması kullanarak tuzlar (salt) ve hash'ler.
    Veritabanında asla düz metin şifre saklanmamasını sağlar.
    """
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(pwd_bytes, salt)
    return hashed.decode('utf-8') 

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Kullanıcının girdiği şifreyi, veritabanındaki hash ile karşılaştırır.
    """
    pwd_bytes = plain_password.encode('utf-8')
    hashed_bytes = hashed_password.encode('utf-8')
    return bcrypt.checkpw(pwd_bytes, hashed_bytes)

# --- TOKEN (JWT) YÖNETİMİ ---

def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    """
    Kısa süreli erişim anahtarı (Access Token) oluşturur.
    Uygulama içindeki yetkili isteklere bu token ile cevap verilir.
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)    

    to_encode.update({"exp": expire})
    if "sub" in to_encode:
        to_encode["sub"] = str(to_encode["sub"])

    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def create_refresh_token(user_id: int) -> str:
    """
    Uzun süreli yenileme anahtarı (Refresh Token) oluşturur.
    Access token süresi dolduğunda yeni bir session başlatmak için kullanılır.
    """
    expire = datetime.utcnow() + timedelta(days=30) # 30 gün geçerli
    to_encode = {
        "sub": str(user_id),
        "type": "refresh",
        "exp": expire
    }
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def verify_token(token: str) -> dict:
    """Token'ın imzasını ve süresini kontrol eder."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        raise JWTError("Token geçersiz veya süresi dolmuş")            

# --- BAĞIMLILIK ENJEKSİYONU (DEPENDENCIES) ---

security = HTTPBearer()

def get_current_user(
    token: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """
    **Dependency Injection:** Her istekte header'daki token'ı kontrol eder.
    Geçerli ise veritabanından kullanıcıyı çeker ve endpoint'e teslim eder.
    """
    token = token.credentials
    try:
        payload = verify_token(token)
    except:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "INVALID_TOKEN", "message": "Oturum geçersiz, lütfen tekrar giriş yapın."}
        )

    # Refresh token ile işlem yapmaya çalışanları engelle
    if payload.get("type") == "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "INVALID_TOKEN_TYPE", "message": "Access token gerekli"}
        )        

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "INVALID_TOKEN", "message": "Token verisi eksik"}
        )   
    
    user = db.query(User).filter(User.id == int(user_id)).first()

    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Kullanıcı bulunamadı")

    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Hesabınız pasif durumda")
    
    return user    

def get_admin_user(current_user: User = Depends(get_current_user)) -> User:
    """
    **Yetkilendirme:** Sadece rolü 'admin' veya 'super_admin' olanların 
    geçebileceği bir güvenlik kapısıdır.
    """
    if current_user.role not in ['admin', 'super_admin']:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail={"code": "ADMIN_REQUIRED", "message": "Bu işlem için yetkiniz bulunmuyor."}
        )
    return current_user