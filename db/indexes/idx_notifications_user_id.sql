-- notifications tablosunda silinmemiş (deleted_at IS NULL) kayıtların
-- kullanıcıya (user_id) göre daha hızlı sorgulanabilmesi için
-- user_id alanı üzerinde koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_notifications_user_id
ON notifications(user_id)
WHERE deleted_at IS NULL;
