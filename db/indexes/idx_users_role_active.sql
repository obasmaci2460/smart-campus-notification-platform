-- users tablosunda silinmemiş (deleted_at IS NULL) kullanıcıların
-- rol bilgisine göre daha hızlı sorgulanabilmesi için
-- role alanı üzerinde koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_users_role_active
ON users(role)
WHERE deleted_at IS NULL;
