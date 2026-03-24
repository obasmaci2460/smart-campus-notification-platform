import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.api import auth, notifications, users

# FastAPI Uygulama Yapılandırması
app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    description="Akıllı Kampüs Bildirim Platformu API - Kampüs içi güvenlik ve altyapı yönetim sistemi."
)

# --- CORS Yapılandırması ---
# Flutter veya web tarafındaki istemcilerin API'ye erişebilmesi için gerekli izinler.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Geliştirme aşamasında her yerden erişime izin verir
    allow_credentials=True,
    allow_methods=["*"],  # GET, POST, PUT, DELETE vb. tüm metodlara izin verir
    allow_headers=["*"],
)

# --- Statik Dosya Yönetimi ---
# Yüklenen fotoğrafların sunulması için 'uploads' klasörünü dışarı açar.
UPLOAD_DIR = "uploads"
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# --- Kök ve Sağlık Kontrolü ---

@app.get('/', tags=["System"])
def root():
    """API ana giriş noktası ve durum bilgisi."""
    return {
        "message": "Campus Notification API",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/api/v1/health", tags=["System"])
def health_check():
    """Sistemin çalışabilirliğini (Liveness) kontrol eden endpoint."""
    return { 
        "success": True,
        "data": {
            "status": "healthy",
            "version": "1.0.0",
            "app_name": settings.APP_NAME
        }
    }

# --- Router Kayıtları (API v1) ---
# auth, notifications ve users router'larını tek bir prefix altında birleştirir.

app.include_router(auth.router, prefix="/api/v1")
app.include_router(notifications.router, prefix='/api/v1')
app.include_router(users.router, prefix='/api/v1')