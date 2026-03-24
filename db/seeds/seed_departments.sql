-- departments tablosuna üniversitede yer alan
-- fakülte, bölüm ve idari birimlerin başlangıç (seed) verileri eklenmektedir
-- is_active alanı, bölümün sistemde aktif olup olmadığını belirtir
INSERT INTO departments (name, is_active)
VALUES
    (N'Bilgisayar Mühendisliği', 1),
    (N'Elektrik-Elektronik Mühendisliği', 1),
    (N'Makine Mühendisliği', 1),
    (N'İnşaat Mühendisliği', 1),
    (N'Endüstri Mühendisliği', 1),
    (N'İşletme', 1),
    (N'İktisat', 1),
    (N'Hukuk', 1),
    (N'Tıp', 1),
    (N'Hemşirelik', 1),
    (N'Mimarlık', 1),
    (N'İç Mimarlık', 1),
    (N'Psikoloji', 1),
    (N'Sosyoloji', 1),
    (N'İletişim', 1),
    (N'Yönetim', 1),
    (N'Fen-Edebiyat', 1),
    (N'Eğitim Fakültesi', 1),
    (N'İdari Personel', 1),
    (N'Öğrenci İşleri', 1);

-- Eklenen bölümlerin doğru şekilde eklendiğini kontrol etmek
-- ve listelemek amacıyla sorgu çalıştırılır
SELECT 
    id,
    name,
    is_active,
    created_at
FROM departments
ORDER BY id;
GO

-- Sistem genelinde kaç adet bölüm olduğunu
-- ve bunlardan kaç tanesinin aktif olduğunu görmek için
-- istatistiksel kontrol sorgusu çalıştırılır
SELECT 
    COUNT(*) AS total_departments,
    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_departments
FROM departments;
GO
