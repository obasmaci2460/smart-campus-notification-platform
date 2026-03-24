-- user_sessions tablosunda henüz çıkış yapılmamış (logout_at IS NULL)
-- aktif kullanıcı oturumlarının daha hızlı sorgulanabilmesi için
-- user_id alanı üzerinde koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_user_sessions_active
ON user_sessions(user_id)
WHERE logout_at IS NULL;
