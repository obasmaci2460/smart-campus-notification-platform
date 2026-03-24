-- sos_usage_tracking tablosu, kullanıcıların SOS (acil durum) bildirimlerini
-- ne zaman tetiklediğini kayıt altına almak için oluşturulmuştur
-- Güvenlik ve istatistik amaçlı takip bu tablo üzerinden yapılır

CREATE TABLE sos_usage_tracking(
	-- SOS kullanım kaydı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- SOS işlemini başlatan kullanıcı
	user_id INT NOT NULL,

	-- SOS olarak işaretlenen bildirim
	notification_id INT NOT NULL,

	-- SOS işleminin tetiklendiği tarih ve saat
	triggered_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_sos_usage_tracking_triggered_at DEFAULT CURRENT_TIMESTAMP,

	-- Primary Key tanımı
	CONSTRAINT PK_sos_usage_tracking_id PRIMARY KEY(id),

	-- SOS işlemini yapan kullanıcının users tablosu ile ilişkisi
	CONSTRAINT FK_sos_usage_tracking_users_user_id 
		FOREIGN KEY (user_id) 
		REFERENCES users(id) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,  

	-- SOS işleminin ait olduğu bildirimin notifications tablosu ile ilişkisi
	-- Bildirim silinirse ilgili SOS kayıtları da silinir
	CONSTRAINT FK_sos_usage_tracking_notifications_notification_id 
		FOREIGN KEY (notification_id) 
		REFERENCES notifications(id) 
		ON DELETE CASCADE
		ON UPDATE CASCADE
);
