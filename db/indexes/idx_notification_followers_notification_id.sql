-- notification_followers tablosunda notification_id alanına göre
-- yapılan sorguların daha hızlı çalışması için
-- non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_notification_followers_notification_id
ON notification_followers(notification_id);
