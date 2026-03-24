-- sos_usage_tracking tablosunda kullanıcıya göre
-- acil durum tetikleme kayıtlarının (SOS)
-- tarih sırasına göre daha hızlı sorgulanabilmesi için
-- user_id ve triggered_at (DESC) alanlarını kapsayan non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_sos_usage_tracking_user_id_triggered_at
ON sos_usage_tracking(user_id, triggered_at DESC);
