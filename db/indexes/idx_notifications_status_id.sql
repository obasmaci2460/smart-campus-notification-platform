/* ÝNDEKS ADI: idx_notifications_status_id
    TABLO: notifications
    ALAN: status_id
    TÜR: NONCLUSTERED INDEX (Filtered)
    
    AÇIKLAMA: 
    - Bildirimlerin durumuna göre (Açýk, Ýnceleniyor, Çözüldü) yapýlan sorgularý hýzlandýrýr.
    - 'WHERE deleted_at IS NULL' filtresi sayesinde sadece sistemde aktif olan (silinmemiþ) 
      kayýtlarý kapsar. Bu, indeks boyutunu küçültür ve disk/bellek performansýný artýrýr.
    - Flutter tarafýnda "Çözülenleri listele" veya "Bekleyenleri göster" gibi filtreleme 
      iþlemlerinde harita performansýný doðrudan etkiler.
*/

CREATE NONCLUSTERED INDEX idx_notifications_status_id 
ON notifications(status_id) 
WHERE deleted_at IS NULL;