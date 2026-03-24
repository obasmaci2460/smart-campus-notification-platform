-- failed_login_attempts tablosunda, hesabı geçici olarak kilitlenmiş
-- (locked_until değeri NULL olmayan) kayıtların daha hızlı bulunabilmesi için
-- email ve locked_until alanlarını kapsayan koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_failed_login_attempts_locked
ON failed_login_attempts(email, locked_until)
WHERE locked_until IS NOT NULL;
