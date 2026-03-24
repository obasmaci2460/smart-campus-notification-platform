-- failed_login_attempts tablosu, başarısız giriş denemelerini takip etmek için oluşturulmuştur
-- Güvenlik amacıyla e-posta, IP adresi ve deneme zamanı bilgileri saklanır

CREATE TABLE failed_login_attempts(
	-- Başarısız giriş kaydı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Giriş denemesinde kullanılan e-posta adresi
	email VARCHAR(255) NOT NULL,

	-- Giriş denemesinin yapıldığı IP adresi
	ip_address VARCHAR(45) NOT NULL,

	-- Giriş denemesinin yapıldığı tarih ve saat
	attempted_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_failed_login_attempts_attempted_at DEFAULT CURRENT_TIMESTAMP,

	-- Hesap kilitlendiyse kilidin kalkacağı tarih
	locked_until DATETIME2(0) NULL,

	-- Primary Key tanımı
	CONSTRAINT PK_failed_login_attempts_id PRIMARY KEY(id),

	-- Kilitlenme tarihinin, deneme tarihinden sonra olmasını sağlayan kontrol
	CONSTRAINT CK_failed_login_attempts_locked_until 
		CHECK (locked_until IS NULL OR locked_until > attempted_at)
);
