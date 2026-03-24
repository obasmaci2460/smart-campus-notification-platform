from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from .config import settings

# Veri tabanı motorunu (Engine) oluşturuyoruz.
# pool_pre_ping=True: Bağlantı kopmalarını otomatik tespit edip yeniden bağlanmayı sağlar.
engine = create_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG, # Geliştirme aşamasında SQL sorgularını terminale basar.
    pool_pre_ping=True  
)

# Her istek (request) için yeni bir session üretecek fabrika yapısı.
SessionLocal = sessionmaker(
    autocommit=False, 
    autoflush=False, 
    bind=engine
)

# Modellerin (User, Notification vb.) miras alacağı temel sınıf.
Base = declarative_base()

def get_db():
    """
    FastAPI Dependency Injection için veri tabanı session üreticisi.
    Her istekte yeni bir bağlantı açar ve işlem bitince güvenli bir şekilde kapatır.
    """
    db = SessionLocal()
    try:
        yield db 
    finally:
        db.close()