-- notification_followers tablosunda user_id alanına göre
-- yapılan sorguların daha hızlı çalışması için
-- non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_notification_followers_user_id
ON notification_followers(user_id);
