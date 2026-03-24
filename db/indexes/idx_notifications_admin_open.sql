-- notifications tablosunda admin tarafından açık veya işlemde olan
-- (status_id = 1 veya 2) ve silinmemiş (deleted_at IS NULL) kayıtların
-- tarihine göre daha hızlı listelenebilmesi için
-- status_id ve created_at (DESC) alanlarını kapsayan koşullu (filtered) non-clustered index oluşturulmuştur
CREATE NONCLUSTERED INDEX idx_notifications_admin_open
ON notifications(status_id, created_at DESC)
WHERE status_id IN (1, 2)
  AND deleted_at IS NULL;

