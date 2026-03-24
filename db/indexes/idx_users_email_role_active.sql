-- users tablosunda aktif (is_active = 1) ve silinmemiş (deleted_at IS NULL)
-- kullanıcıların e-posta ve rol bilgilerine göre
-- daha hızlı sorgulanabilmesi için
-- email ve role alanlarını kapsayan koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_users_email_role_active
ON users(email, role)
WHERE is_active = 1
  AND deleted_at IS NULL;
