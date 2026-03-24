-- notification_preferences tablosu, kullanıcıların hangi tür bildirimleri
-- almak istediklerini belirlemek için oluşturulmuştur
-- Her kullanıcı için kategori bazlı bildirim tercihleri tutulur

CREATE TABLE notification_preferences(

	-- Bildirim tercih kaydı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Tercihlerin ait olduğu kullanıcı
	user_id INT NOT NULL,

	-- Güvenlik bildirimlerini alıp almadığını belirtir
	notify_security BIT NOT NULL 
		CONSTRAINT DF_notification_preferences_notify_security DEFAULT 1,

	-- Bakım bildirimlerini alıp almadığını belirtir
	notify_maintenance BIT NOT NULL 
		CONSTRAINT DF_notification_preferences_notify_maintenance DEFAULT 1,

	-- Temizlik bildirimlerini alıp almadığını belirtir
	notify_cleaning BIT NOT NULL 
		CONSTRAINT DF_notification_preferences_notify_cleaning DEFAULT 1,

	-- Altyapı bildirimlerini alıp almadığını belirtir
	notify_infrastructure BIT NOT NULL 
		CONSTRAINT DF_notification_preferences_notify_infrastructure DEFAULT 1,

	-- Diğer kategorideki bildirimleri alıp almadığını belirtir
	notify_other BIT NOT NULL 
		CONSTRAINT DF_notification_preferences_notify_other DEFAULT 1,

	-- Tercih kaydının oluşturulma tarihi
	created_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_notification_preferences_created_at DEFAULT CURRENT_TIMESTAMP,

	-- Tercih kaydının son güncellenme tarihi
	updated_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_notification_preferences_updated_at DEFAULT CURRENT_TIMESTAMP,

	-- Primary Key tanımı
	CONSTRAINT PK_notification_preferences_id PRIMARY KEY (id),
	
	-- Bildirim tercihinin bir kullanıcıya ait olmasını sağlayan Foreign Key
	-- Kullanıcı silinirse tercih kayıtları da silinir
	CONSTRAINT FK_notification_preferences_users_user_id 
		FOREIGN KEY (user_id) 
		REFERENCES users(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	-- Her kullanıcı için yalnızca bir adet bildirim tercihi kaydı olmasını sağlar
	CONSTRAINT UQ_notification_preferences_user_id UNIQUE (user_id)

);
