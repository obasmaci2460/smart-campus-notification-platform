-- fcm_tokens tablosunda sadece aktif olan (is_active = 1)
-- kullanıcı tokenlarının daha hızlı sorgulanabilmesi için
-- user_id alanı üzerinde koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_fcm_tokens_active
ON fcm_tokens(user_id)
WHERE is_active = 1;
