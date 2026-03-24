-- notification_photos tablosunda notification_id alanına göre
-- yapılan sorguların daha hızlı çalışması için
-- non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_notification_photos_notification_id
ON notification_photos(notification_id);
