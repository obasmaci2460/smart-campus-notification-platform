-- notifications tablosunda konuma (location) bağlı sorguların
-- daha hızlı çalışabilmesi için spatial (coğrafi) index oluşturulmuştur
-- Bu index, harita üzerinde yakınlık ve konum bazlı aramaları hızlandırmak için kullanılır
CREATE SPATIAL INDEX idx_notifications_location
ON notifications(location)
USING GEOGRAPHY_GRID
WITH (
	-- Grid seviyeleri ayarlanarak konumsal sorgularda
	-- daha hassas ve performanslı sonuçlar elde edilmesi amaçlanmıştır
	GRIDS=(
		LEVEL_1=LOW,
		LEVEL_2=LOW,
		LEVEL_3=HIGH,
		LEVEL_4=HIGH
	),
	-- Bir nesne için kullanılacak maksimum hücre sayısı belirlenmiştir
	CELLS_PER_OBJECT=16
);
--“Bildirimlerin harita üzerinde konuma göre hızlı sorgulanabilmesi için spatial index tanımlanmıştır.”