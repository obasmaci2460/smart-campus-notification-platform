-- user_sessions tablosu, kullanıcıların sistemde açtıkları oturumları
-- takip etmek ve kayıt altına almak için oluşturulmuştur
-- Giriş, çıkış, cihaz ve son aktivite bilgileri burada tutulur

CREATE TABLE user_sessions(
	-- Oturum kaydı için benzersiz kimlik numarası
	id BIGINT NOT NULL IDENTITY(1,1),

	-- Oturumu açan kullanıcı
	user_id INT NOT NULL,

	-- Kullanıcının giriş yaptığı tarih ve saat
	login_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_user_sessions_login_at DEFAULT CURRENT_TIMESTAMP,

	-- Kullanıcının çıkış yaptığı tarih ve saat (çıkış yapmadıysa NULL)
	logout_at DATETIME2(0) NULL,

	-- Oturumun açıldığı IP adresi
	ip_address VARCHAR(45) NOT NULL,

	-- Kullanıcının tarayıcı / cihaz bilgisi
	user_agent VARCHAR(255) NULL,

	-- Oturumun açıldığı platform bilgisi (ios veya android)
	platform VARCHAR(10) NOT NULL,

	-- Oturumda kullanılan FCM token bilgisi (opsiyonel)
	fcm_token_id INT NULL,

	-- Kullanıcının son aktivite zamanı
	last_activity DATETIME2(0) NOT NULL 
		CONSTRAINT DF_user_sessions_last_activity DEFAULT CURRENT_TIMESTAMP,

	-- Primary Key tanımı
	CONSTRAINT PK_user_sessions_id PRIMARY KEY(id),

	-- Oturumun bir kullanıcıya ait olmasını sağlayan Foreign Key
	CONSTRAINT FK_user_sessions_users_user_id 
		FOREIGN KEY (user_id) 
		REFERENCES users(id) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,  

	-- Oturumda kullanılan FCM token'ın fcm_tokens tablosu ile ilişkisi
	-- Token silinirse oturum kaydındaki referans NULL yapılır
	CONSTRAINT FK_user_sessions_fcm_tokens_fcm_token_id 
		FOREIGN KEY (fcm_token_id) 
		REFERENCES fcm_tokens(id) 
		ON DELETE SET NULL
		ON UPDATE NO ACTION,  

	-- Platform bilgisinin sadece ios veya android olmasını sağlar
	CONSTRAINT CK_user_sessions_platform 
		CHECK (platform IN ('ios','android')),

	-- Çıkış zamanının giriş zamanından önce olmamasını sağlar
	CONSTRAINT CK_user_sessions_logout_at 
		CHECK (logout_at IS NULL OR logout_at >= login_at),

	-- IP adresi alanının boş olmamasını sağlar
	CONSTRAINT CK_user_sessions_ip_address 
		CHECK (LEN(RTRIM(LTRIM(ip_address))) > 0)
);
