-- admin_notes tablosunda notification_id alanına göre
-- yapılan sorguların daha hızlı çalışması için
-- non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_admin_notes_notification_id
ON admin_notes(notification_id);
