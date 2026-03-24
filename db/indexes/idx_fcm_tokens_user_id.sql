-- fcm_tokens tablosunda user_id alanına göre
-- yapılan sorguların daha hızlı çalışması için
-- non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_fcm_tokens_user_id
ON fcm_tokens(user_id);
