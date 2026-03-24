-- broadcast_messages tablosunda mesajı gönderen kullanıcıya göre
-- yapılan sorguların daha hızlı çalışması için
-- sent_by_user_id alanı üzerinde non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_broadcast_messages_sent_by_user_id
ON broadcast_messages(sent_by_user_id);
