-- failed_login_attempts tablosunda e-posta adresine ve
-- deneme zamanına göre yapılan sorguların daha hızlı çalışması için
-- email ve attempted_at (DESC) alanlarını kapsayan non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_failed_login_attempts_email_attempted_at
ON failed_login_attempts(email, attempted_at DESC);
