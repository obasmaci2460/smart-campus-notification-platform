-- admin_notes tablosunda admin_user_id alanına göre
-- yapılan sorguların daha hızlı çalışması için
-- non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_admin_notes_admin_user_id
ON admin_notes(admin_user_id);
