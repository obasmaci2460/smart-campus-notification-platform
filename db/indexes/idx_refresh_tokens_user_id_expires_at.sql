-- refresh_tokens tablosunda iptal edilmemiş (is_revoked = 0) tokenların
-- kullanıcıya ve bitiş tarihine göre daha hızlı sorgulanabilmesi için
-- user_id ve expires_at alanlarını kapsayan koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_refresh_tokens_user_id_expires_at
ON refresh_tokens(user_id, expires_at)
WHERE is_revoked = 0;
