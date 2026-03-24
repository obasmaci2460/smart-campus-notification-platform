-- users tablosu, sistemde yer alan kullanıcıların temel bilgilerini tutmak için oluşturulmuştur
-- Kullanıcı bilgileri, rol yapısı, bölüm ilişkisi ve aktiflik durumları burada saklanır

CREATE TABLE users(
	
	-- Kullanıcı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Kullanıcının e-posta adresi (üniversite uzantılı)
	email VARCHAR(255) NOT NULL,

	-- Kullanıcının şifrelenmiş parola bilgisi
	password_hash VARCHAR(60) NOT NULL,

	-- Kullanıcının adı
	first_name NVARCHAR(50) NOT NULL,

	-- Kullanıcının soyadı
	last_name NVARCHAR(50) NOT NULL,

	-- Kullanıcının bağlı olduğu bölüm
	department_id INT NOT NULL,

	-- Kullanıcının telefon numarası (opsiyonel)
	phone VARCHAR(20) NULL,

	-- Kullanıcının sistemdeki rolü (varsayılan: user)
	role VARCHAR(15) NOT NULL 
		CONSTRAINT DF_users_role DEFAULT 'user',

	-- Kullanıcının süper admin olup olmadığını belirtir
	is_super_admin BIT NOT NULL 
		CONSTRAINT DF_users_is_super_admin DEFAULT 0,

	-- Kullanıcının aktiflik durumu
	is_active BIT NOT NULL 
		CONSTRAINT DF_users_is_active DEFAULT 1,

	-- Kullanıcının oluşturulma tarihi
	created_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_users_created_at DEFAULT CURRENT_TIMESTAMP,

	-- Kullanıcının son güncellenme tarihi
	updated_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_users_updated_at DEFAULT CURRENT_TIMESTAMP,

	-- Kullanıcının silinme tarihi (soft delete için)
	deleted_at DATETIME2(0) NULL,

	-- Primary Key tanımı
	CONSTRAINT PK_users_id PRIMARY KEY (id),

	-- Kullanıcının bir bölüme bağlı olmasını sağlayan Foreign Key
	-- Bölüm silinirse kullanıcı silinmez, güncelleme olursa cascade edilir
	CONSTRAINT FK_users_department_id 
		FOREIGN KEY (department_id) 
		REFERENCES departments(id)
		ON DELETE NO ACTION
		ON UPDATE CASCADE,

	-- E-posta adreslerinin benzersiz olmasını sağlar
	CONSTRAINT UQ_users_email UNIQUE (email),

	-- E-posta adresinin geçerli ve üniversite uzantılı olmasını zorunlu kılar
	CONSTRAINT CK_users_email 
		CHECK (
			email LIKE '%_@_%.__%' 
			AND (email LIKE '%.edu' OR email LIKE '%.edu.%')
		),

	-- Kullanıcı rolünün sadece tanımlı değerlerden biri olmasını sağlar
	CONSTRAINT CK_users_role 
		CHECK (role IN ('admin','user','super_admin')),

	-- Kullanıcının adının boş olmamasını sağlar
	CONSTRAINT CK_users_first_name 
		CHECK (LEN(LTRIM(RTRIM(first_name))) > 0),

	-- Kullanıcının soyadının boş olmamasını sağlar
	CONSTRAINT CK_users_last_name 
		CHECK (LEN(LTRIM(RTRIM(last_name))) > 0),

	-- Süper admin olan kullanıcıların rolünün mutlaka 'super_admin' olmasını zorunlu kılar
	CONSTRAINT CK_users_is_super_admin 
		CHECK (
			(is_super_admin = 0) 
			OR ((is_super_admin = 1) AND (role = 'super_admin'))
		),

	-- E-posta alanının sadece boşluklardan oluşmasını engeller
	CONSTRAINT CK_users_email_min 
		CHECK (LEN(LTRIM(RTRIM(email))) > 0)
);
