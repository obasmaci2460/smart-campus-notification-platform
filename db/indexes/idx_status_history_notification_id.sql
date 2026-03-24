-- status_history tablosunda bildirimlere ait durum geçmişinin
-- daha hızlı sorgulanabilmesi için
-- notification_id alanı üzerinde non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_status_history_notification_id
ON status_history(notification_id);
