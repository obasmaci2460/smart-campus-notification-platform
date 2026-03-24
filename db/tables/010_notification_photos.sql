-- notification_photos tablosu, bildirimlere ait fotoğraf bilgilerini tutmak için oluşturulmuştur
-- Fotoğrafların dosya bilgileri, sıralaması ve yüklenme zamanı burada saklanır

CREATE TABLE notification_photos(

	-- Fotoğraf kaydı için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Fotoğrafın ait olduğu bildirim
	notification_id INT NOT NULL,

	-- Fotoğrafın S3 üzerindeki anahtar değeri
	s3_key VARCHAR(500) NOT NULL,

	-- Fotoğrafın S3 üzerindeki erişim adresi
	s3_url VARCHAR(1000) NOT NULL,

	-- Fotoğraf dosyasının byte cinsinden boyutu
	file_size_bytes INT NOT NULL,

	-- Fotoğrafın MIME türü
	mime_type VARCHAR(20) NOT NULL,

	-- Bildirim içindeki fotoğraf sırası
	display_order TINYINT NOT NULL,

	-- Fotoğrafın yüklendiği tarih
	uploaded_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_notification_photos_uploaded_at DEFAULT CURRENT_TIMESTAMP,

	-- Primary Key tanımı
	CONSTRAINT PK_notification_photos_id PRIMARY KEY(id),

	-- Fotoğrafın bir bildirime ait olmasını sağlayan Foreign Key
	-- Bildirim silinirse fotoğraflar da silinir
	CONSTRAINT FK_notification_photos_notifications_notification_id 
		FOREIGN KEY (notification_id) 
		REFERENCES notifications(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	
	-- Aynı bildirim için aynı sırada birden fazla fotoğraf eklenmesini engeller
	CONSTRAINT UQ_notification_photos_notification_id_display_order 
		UNIQUE (notification_id, display_order),

	-- Fotoğraf dosya boyutunun maksimum 5 MB olmasını sağlar
	CONSTRAINT CK_notification_photos_file_size_bytes 
		CHECK (file_size_bytes <= 5242880),

	-- Sadece JPEG ve PNG formatındaki fotoğraflara izin verir
	CONSTRAINT CK_notification_photos_mime_type 
		CHECK (mime_type IN ('image/jpeg','image/png')),

	-- Fotoğraf sırasının 1 ile 5 arasında olmasını sağlar
	CONSTRAINT CK_notification_photos_display_order 
		CHECK (display_order >= 1 AND display_order <= 5),

	-- S3 anahtar bilgisinin boş olmamasını sağlar
	CONSTRAINT CK_notification_photos_s3_key 
		CHECK (LEN(RTRIM(LTRIM(s3_key))) > 0),

	-- S3 URL bilgisinin boş olmamasını sağlar
	CONSTRAINT CK_notification_photos_s3_url 
		CHECK (LEN(RTRIM(LTRIM(s3_url))) > 0)

);
