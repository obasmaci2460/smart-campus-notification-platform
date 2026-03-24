-- fcm_tokens tablosu, kullanıcıların mobil bildirimler için kullanılan
-- Firebase Cloud Messaging (FCM) token bilgilerini tutmak için oluşturulmuştur
-- Her token hangi kullanıcıya ve hangi platforma ait olduğu bilgisiyle saklanır

CREATE TABLE fcm_tokens(

	-- FCM token kaydı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Token’ın ait olduğu kullanıcı
	user_id INT NOT NULL,

	-- Firebase tarafından verilen FCM token değeri
	fcm_token VARCHAR(255) NOT NULL,

	-- Token’ın ait olduğu platform (ios veya android)
	platform VARCHAR(10) NOT NULL,

	-- Token’ın aktif olup olmadığını belirtir
	is_active BIT NOT NULL 
		CONSTRAINT DF_fcm_tokens_is_active DEFAULT 1,

	-- Token’ın oluşturulma tarihi
	created_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_fcm_tokens_created_at DEFAULT CURRENT_TIMESTAMP,

	-- Token’ın son güncellenme tarihi
	updated_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_fcm_tokens_updated_at DEFAULT CURRENT_TIMESTAMP,

	-- Primary Key tanımı
	CONSTRAINT PK_fcm_tokens_id PRIMARY KEY(id),

	-- FCM token’ın bir kullanıcıya ait olmasını sağlayan Foreign Key
	-- Kullanıcı silinirse token kayıtları da silinir
	CONSTRAINT FK_fcm_tokens_users_user_id 
		FOREIGN KEY (user_id) 
		REFERENCES users(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	-- Aynı FCM token’ın birden fazla kez eklenmesini engeller
	CONSTRAINT UQ_fcm_tokens_fcm_token UNIQUE (fcm_token),

	-- FCM token alanının boş olmamasını sağlar
	CONSTRAINT CK_fcm_tokens_fcm_token 
		CHECK (LEN(LTRIM(RTRIM(fcm_token))) > 0),

	-- Platform bilgisinin sadece ios veya android olmasını sağlar
	CONSTRAINT CK_fcm_tokens_platform 
		CHECK (platform IN ('ios','android'))

);
