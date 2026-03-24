-- status_history tablosu, bir bildirimin durum değişikliklerini geçmişe yönelik
-- izlemek ve kayıt altına almak için oluşturulmuştur
-- Bildirimin eski ve yeni durumu, değişikliği yapan kullanıcı ve zaman bilgisi tutulur

CREATE TABLE status_history(
	-- Durum geçmişi kaydı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Durumu değişen bildirim
	notification_id INT NOT NULL,

	-- Bildirimin önceki durumu
	old_status_id TINYINT NOT NULL,

	-- Bildirimin yeni durumu
	new_status_id TINYINT NOT NULL,

	-- Durum değişikliğini yapan kullanıcı
	changed_by_user_id INT NOT NULL,

	-- Durum değişikliğinin yapıldığı tarih
	changed_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_status_history_changed_at DEFAULT CURRENT_TIMESTAMP,

	-- Primary Key tanımı
	CONSTRAINT PK_status_history_id PRIMARY KEY(id),

	-- Kayıtların bir bildirime ait olmasını sağlayan Foreign Key
	-- Bildirim silinirse durum geçmişi kayıtları da silinir
	CONSTRAINT FK_status_history_notifications_notification_id 
		FOREIGN KEY(notification_id) 
		REFERENCES notifications(id) 
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	-- Eski durum bilgisinin statuses tablosu ile ilişkisi
	CONSTRAINT FK_status_history_statuses_old_status_id 
		FOREIGN KEY(old_status_id) 
		REFERENCES statuses(id) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,  

	-- Yeni durum bilgisinin statuses tablosu ile ilişkisi
	CONSTRAINT FK_status_history_statuses_new_status_id 
		FOREIGN KEY(new_status_id) 
		REFERENCES statuses(id) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,  

	-- Durum değişikliğini yapan kullanıcının users tablosu ile ilişkisi
	CONSTRAINT FK_status_history_users_changed_by_user_id 
		FOREIGN KEY(changed_by_user_id) 
		REFERENCES users(id) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,  

	-- Eski ve yeni durumların aynı olmamasını sağlar
	CONSTRAINT CK_status_history_old_status_id_new_status_id 
		CHECK (old_status_id != new_status_id)
);
