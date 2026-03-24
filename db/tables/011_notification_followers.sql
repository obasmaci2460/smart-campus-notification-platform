-- notification_followers tablosu, kullanıcıların bir bildirimi takip edip etmediğini tutmak için oluşturulmuştur
-- Hangi kullanıcının hangi bildirimi ne zaman takip etmeye başladığı bilgisi burada saklanır

CREATE TABLE notification_followers(
	-- Takip kaydı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Takip edilen bildirim
	notification_id INT NOT NULL,

	-- Bildirimi takip eden kullanıcı
	user_id INT NOT NULL,

	-- Takip işleminin yapıldığı tarih
	followed_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_notification_followers_followed_at DEFAULT CURRENT_TIMESTAMP,

	-- Primary Key tanımı
	CONSTRAINT PK_notification_followers_id PRIMARY KEY(id),

	-- Takibin bir bildirime ait olmasını sağlayan Foreign Key
	-- Bildirim silinirse ilgili takip kayıtları da silinir
	CONSTRAINT FK_notification_followers_notifications_notification_id 
		FOREIGN KEY (notification_id) 
		REFERENCES notifications(id) 
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	-- Takibi yapan kullanıcının kullanıcı tablosu ile ilişkisi
	CONSTRAINT FK_notification_followers_users_user_id 
		FOREIGN KEY (user_id) 
		REFERENCES users(id) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,  

	-- Aynı kullanıcının aynı bildirimi birden fazla kez takip etmesini engeller
	CONSTRAINT UQ_notification_followers_notification_id_user_id 
		UNIQUE (notification_id, user_id)
);
