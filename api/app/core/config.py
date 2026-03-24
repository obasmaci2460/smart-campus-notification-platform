from pydantic_settings import BaseSettings 

class Settings(BaseSettings):
    """
    Uygulama genelindeki tüm yapılandırma ayarlarını yönetir.
    
    Verileri kök dizindeki '.env' dosyasından otomatik olarak yükler.
    Bu yapı, hassas verilerin (şifreler, anahtarlar) koddan ayrıştırılmasını sağlar.
    """
    # Veritabanı Bağlantı Ayarları
    DB_DRIVER: str     
    DB_SERVER: str   
    DB_NAME: str     
    DB_USER: str    
    DB_PASSWORD: str 

    # Güvenlik ve JWT Ayarları
    SECRET_KEY: str
    ALGORITHM: str = "HS256"               
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440 # 24 Saat

    # Uygulama Genel Ayarları
    APP_NAME: str = "Campus Notification API"
    DEBUG: bool = True

    @property 
    def DATABASE_URL(self) -> str:
        """
        Gelen parametrelerden SQLAlchemy uyumlu MSSQL bağlantı dizesini oluşturur.
        Boşluk içeren Driver isimlerini (+ ile) URL güvenli hale getirir.
        """
        return (
            f"mssql+pyodbc://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_SERVER}/{self.DB_NAME}"
            f"?driver={self.DB_DRIVER.replace(' ', '+')}"
            f"&Encrypt=yes&TrustServerCertificate=yes"
        )

    class Config:
        env_file = ".env"
        case_sensitive = True

# Tek bir instance oluşturarak her yerden erişilmesini sağlıyoruz (Singleton deseni)
settings = Settings()