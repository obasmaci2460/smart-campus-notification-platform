-- notifications tablosunda silinmemiş (deleted_at IS NULL) kayıtların
-- kategoriye göre daha hızlı sorgulanabilmesi için
-- category_id alanı üzerinde koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_notifications_category_id
ON notifications(category_id)
WHERE deleted_at IS NULL;
