-- categories tablosuna sistemde kullanılacak
-- bildirim kategorilerinin başlangıç (örnek) verileri eklenmektedir
-- Her kategori için ad, ekranda görünen isim, ikon, renk ve aktiflik bilgisi tutulur
INSERT INTO categories (name, display_name, icon, color_hex, is_active)
VALUES
    ('security', N'Güvenlik', 'security', '#E53935', 1),
    ('maintenance', N'Bakım', 'build', '#FB8C00', 1),
    ('cleaning', N'Temizlik', 'cleaning_services', '#FDD835', 1),
    ('infrastructure', N'Altyapı', 'construction', '#1E88E5', 1),
    ('other', N'Diğer', 'more_horiz', '#43A047', 1);

-- Eklenen kategorilerin doğru şekilde eklendiğini
-- kontrol etmek ve listelemek amacıyla sorgu çalıştırılır
SELECT id, name, display_name, icon, color_hex, is_active
FROM categories
ORDER BY id;
GO
