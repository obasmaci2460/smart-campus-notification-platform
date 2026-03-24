-- broadcast_messages tablosunda gönderim tarihine göre
-- yapılan sıralama ve arama işlemlerinin daha hızlı çalışması için
-- sent_at alanı üzerinde (DESC) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_broadcast_messages_sent_at
ON broadcast_messages(sent_at DESC);
