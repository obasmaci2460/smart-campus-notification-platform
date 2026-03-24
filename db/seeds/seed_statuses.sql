-- statuses tablosuna bildirimlerin durumlarını temsil eden
-- başlangıç (seed) verileri eklenmektedir
-- Her durum için sistem adı, ekranda görünen adı, renk bilgisi ve aktiflik durumu tutulur
INSERT INTO statuses (name, display_name, color_hex, is_active)
VALUES
    ('open',       N'Açık',        '#F59E0B', 1),
    ('in_review',  N'İnceleniyor',  '#3B82F6', 1),
    ('resolved',   N'Çözüldü',      '#16A34A', 1),
    ('spam',       N'Spam',         '#DC2626', 1);

-- Eklenen durumların doğru şekilde eklendiğini
-- kontrol etmek ve listelemek amacıyla sorgu çalıştırılır
SELECT 
    id, 
    name, 
    display_name, 
    color_hex, 
    is_active 
FROM statuses
ORDER BY id;
GO
