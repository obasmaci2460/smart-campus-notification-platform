-- notifications tablosunda silinmemiş (deleted_at IS NULL) kayıtların
-- oluşturulma tarihine göre daha hızlı listelenebilmesi için
-- created_at alanı üzerinde (DESC) koşullu non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_notifications_created_at
ON notifications(created_at DESC)
WHERE deleted_at IS NULL;
