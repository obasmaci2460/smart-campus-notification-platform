-- admin_notes tablosu, yöneticilerin (admin) bildirimler ile ilgili
-- ekledikleri notları tutmak için oluşturulmuştur
-- Her notun hangi bildirim ve hangi admin tarafından eklendiği bilgisi saklanır

CREATE TABLE admin_notes(
	-- Admin notu için benzersiz kimlik numarası
	id INT NOT NULL IDENTITY(1,1),

	-- Notun ait olduğu bildirim
	notification_id INT NOT NULL,

	-- Notu ekleyen admin kullanıcının ID'si
	admin_user_id INT NOT NULL,

	-- Admin tarafından yazılan not içeriği
	note_content NVARCHAR(500) NOT NULL,

	-- Notun oluşturulma tarihi
	created_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_admin_notes_created_at DEFAULT CURRENT_TIMESTAMP,

	-- Notun son güncellenme tarihi
	updated_at DATETIME2(0) NOT NULL 
		CONSTRAINT DF_admin_notes_updated_at DEFAULT CURRENT_TIMESTAMP,

	-- Primary Key tanımı
	CONSTRAINT PK_admin_notes_id PRIMARY KEY(id),

	-- Notun bir bildirime ait olmasını sağlayan Foreign Key
	-- Bildirim silinirse ilgili admin notları da silinir
	CONSTRAINT FK_admin_notes_notifications_notification_id 
		FOREIGN KEY (notification_id) 
		REFERENCES notifications(id) 
		ON DELETE CASCADE
		ON UPDATE CASCADE,

	-- Notu ekleyen admin kullanıcının kullanıcı tablosu ile ilişkisi
	CONSTRAINT FK_admin_notes_users_admin_user_id 
		FOREIGN KEY (admin_user_id) 
		REFERENCES users(id) 
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,  

	-- Not içeriğinin boş olmamasını ve maksimum 500 karakter olmasını sağlar
	CONSTRAINT CK_admin_notes_note_content 
		CHECK (
			LEN(LTRIM(RTRIM(note_content))) >= 1 
			AND LEN(LTRIM(RTRIM(note_content))) <= 500
		)
);
