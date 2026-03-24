-- notifications tablosunda acil durum (is_sos = 1) olan ve
-- silinmemiş (deleted_at IS NULL) kayıtların
-- oluşturulma tarihine göre daha hızlı listelenebilmesi için
-- is_sos ve created_at (DESC) alanlarını kapsayan koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_notifications_sos
ON notifications(is_sos, created_at DESC)
WHERE is_sos = 1
  AND deleted_at IS NULL;
