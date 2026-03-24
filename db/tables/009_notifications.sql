-- notifications tablosu, kullanıcılar tarafından oluşturulan bildirimleri tutmak için oluşturulmuştur
-- Bildirimin kategorisi, durumu, konumu, öncelik bilgileri ve çözülme süreci burada saklanır

CREATE TABLE notifications(
	-- Bildirim için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Bildirimi oluşturan kullanıcı
	user_id INT NOT NULL,

	-- Bildirimin ait olduğu kategori
	category_id TINYINT NOT NULL,

	-- Bildirimin mevcut durumu (varsayılan: open)
	status_id TINYINT NOT NULL 
		CONSTRAINT DF_notifications_status_id DEFAULT 1,

	-- Bildirim başlığı
	title NVARCHAR(80) NOT NULL,

	-- Bildirimin detaylı açıklaması
	description NVARCHAR(500) NOT NULL,

	-- Bildirimin coğrafi konumu (harita bilgisi)
	location GEOGRAPHY NOT NULL,

	-- Bildirimin adres bilgisi
	address NVARCHAR(300) NOT NULL,

	-- Bildirimin acil (SOS) olup olmadığını belirtir
	is_sos BIT NOT NULL 
		CONSTRAINT DF_notifications_is_sos DEFAULT 0,

	-- Bildirimin yüksek öncelikli olup olmadığını belirtir
	is_high_priority BIT NOT NULL 
		CONSTRAINT DF_notifications_is_high_priority DEFAULT 0,

	-- Bildirimin oluşturulma tarihi
	created_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_notifications_created_at DEFAULT CURRENT_TIMESTAMP,

	-- Bildirimin son güncellenme tarihi
	updated_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_notifications_updated_at DEFAULT CURRENT_TIMESTAMP,

	-- Bildirimin çözüldüğü tarih
	resolved_at DATETIME2(0) NULL,

	-- Bildirimin silinme tarihi (soft delete için)
	deleted_at DATETIME2(0) NULL,

	-- Bildirimi çözen admin kullanıcı
	resolved_by_user_id INT NULL,

	-- Primary Key tanımı
	CONSTRAINT PK_notifications_id PRIMARY KEY(id),
	
	-- Bildirimin bir kullanıcıya ait olmasını sağlayan Foreign Key
	CONSTRAINT FK_notifications_users_user_id 
		FOREIGN KEY (user_id) 
		REFERENCES users(id)
		ON DELETE NO ACTION
		ON UPDATE CASCADE,
	
	-- Bildirimin bir kategoriye ait olmasını sağlayan Foreign Key
	CONSTRAINT FK_notifications_categories_category_id 
		FOREIGN KEY (category_id) 
		REFERENCES categories(id)
		ON DELETE NO ACTION 
		ON UPDATE CASCADE,

	-- Bildirimin bir duruma bağlı olmasını sağlayan Foreign Key
	CONSTRAINT FK_notifications_statuses_status_id 
		FOREIGN KEY (status_id) 
		REFERENCES statuses(id)
		ON DELETE NO ACTION
		ON UPDATE CASCADE,
																								 
	-- Bildirimi çözen kullanıcının kullanıcı tablosu ile ilişkisi
	CONSTRAINT FK_notifications_users_resolved_by_user_id 
		FOREIGN KEY (resolved_by_user_id) 
		REFERENCES users(id)
		ON DELETE NO ACTION 
		ON UPDATE NO ACTION,

	-- Başlığın minimum ve maksimum uzunluk kontrolü
	CONSTRAINT CK_notifications_title 
		CHECK (LEN(LTRIM(RTRIM(title))) >= 5 AND LEN(LTRIM(RTRIM(title))) <= 80),

	-- Açıklamanın minimum ve maksimum uzunluk kontrolü
	CONSTRAINT CK_notifications_description 
		CHECK (
			LEN(LTRIM(RTRIM(description))) >= 10 
			AND LEN(LTRIM(RTRIM(description))) <= 500
		),

	-- SOS olan bildirimlerin mutlaka yüksek öncelikli olmasını sağlar
	CONSTRAINT CK_notifications_is_sos_is_high_priority 
		CHECK (is_sos = 0 OR (is_sos = 1 AND is_high_priority = 1)),

	-- Adres bilgisinin boş olmamasını sağlar
	CONSTRAINT CK_notifications_address 
		CHECK (LEN(LTRIM(RTRIM(address))) > 0)

);
