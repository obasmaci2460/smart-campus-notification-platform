-- refresh_tokens tablosu, kullanıcıların oturum yenileme (refresh token) bilgilerini tutmak için oluşturulmuştur
-- Token’ın geçerlilik süresi, iptal durumu ve oluşturulma bilgileri burada saklanır

CREATE TABLE refresh_tokens(

	-- Refresh token kaydı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Token’ın ait olduğu kullanıcı
	user_id INT NOT NULL,

	-- Hashlenmiş refresh token değeri
	token_hash VARCHAR(64) NOT NULL,

	-- Token’ın geçerlilik bitiş tarihi
	expires_at DATETIME2(0) NOT NULL,

	-- Token’ın iptal edilip edilmediğini belirtir
	is_revoked BIT NOT NULL 
		CONSTRAINT DF_refresh_tokens_is_revoked DEFAULT 0,

	-- Token’ın oluşturulma tarihi
	created_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_refresh_tokens_created_at DEFAULT CURRENT_TIMESTAMP,

	-- Token iptal edildiyse iptal edilme tarihi
	revoked_at DATETIME2(0) NULL,

	-- Primary Key tanımı
	CONSTRAINT PK_refresh_tokens_id PRIMARY KEY(id),

	-- Refresh token’ın bir kullanıcıya ait olmasını sağlayan Foreign Key
	-- Kullanıcı silinirse token kayıtları da silinir
	CONSTRAINT FK_refresh_tokens_users_user_id 
		FOREIGN KEY (user_id) 
		REFERENCES users(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	-- Token hash değerlerinin benzersiz olmasını sağlar
	CONSTRAINT UQ_refresh_tokens_token_hash UNIQUE (token_hash),

	-- Token hash uzunluğunun tam olarak 64 karakter olmasını zorunlu kılar
	CONSTRAINT CK_refresh_tokens_token_hash 
		CHECK (LEN(LTRIM(RTRIM(token_hash))) = 64),

	-- Token iptal durumu ile iptal tarihi arasındaki tutarlılığı sağlar
	CONSTRAINT CK_refresh_tokens_is_revoked 
		CHECK (
			(is_revoked = 0 AND revoked_at IS NULL) 
			OR (is_revoked = 1 AND revoked_at IS NOT NULL)
		),

	-- Token’ın bitiş tarihinin oluşturulma tarihinden sonra olmasını sağlar
	CONSTRAINT CK_refresh_tokens_expires_at 
		CHECK (expires_at > created_at)

);
