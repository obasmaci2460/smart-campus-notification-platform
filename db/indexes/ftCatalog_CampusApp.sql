-- Bu kısımda, daha önce oluşturulmuş mu diye kontrol ederek
-- full-text catalog tekrar oluşturulmasın diye önlem alıyoruz
IF NOT EXISTS (SELECT * FROM sys.fulltext_catalogs WHERE name = 'ftCatalog_CampusApp')
BEGIN
	-- Bildirimler üzerinde metin bazlı arama yapabilmek için
	-- full-text catalog oluşturuluyor ve varsayılan olarak ayarlanıyor
	CREATE FULLTEXT CATALOG ftCatalog_CampusApp AS DEFAULT;
END
GO

-- notifications tablosundaki başlık ve açıklama alanları üzerinde
-- kelime bazlı (full-text) arama yapılabilmesi için index oluşturuluyor
CREATE FULLTEXT INDEX ON notifications
(
	-- Bildirim başlığı için full-text arama desteği
	title LANGUAGE 1055,

	-- Bildirim açıklaması için full-text arama desteği
	description LANGUAGE 1055
)
-- Full-text index için kayıtları benzersiz şekilde tanımlayan primary key
KEY INDEX PK_notifications_id

-- Oluşturulan index, ftCatalog_CampusApp katalogu üzerinde tutulur
ON ftCatalog_CampusApp

-- Tabloda ekleme veya güncelleme olduğunda
-- full-text index’in otomatik olarak güncellenmesi sağlanır
WITH CHANGE_TRACKING AUTO
