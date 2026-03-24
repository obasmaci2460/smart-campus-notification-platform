-- user_sessions tablosunda kullanıcıya ait oturumların
-- giriş zamanına göre (login_at) daha hızlı listelenebilmesi için
-- user_id ve login_at (DESC) alanlarını kapsayan non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_user_sessions_user_id_login_at
ON user_sessions(user_id, login_at DESC);
