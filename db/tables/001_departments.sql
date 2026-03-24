-- departments tablosu, üniversitedeki bölüm ve birim bilgilerini tutmak için oluşturulmuştur
-- Her bölüm için ad, aktiflik durumu ve oluşturulma tarihi saklanır

CREATE TABLE departments (

    -- Bölüm için benzersiz kimlik numarası
    id INT NOT NULL IDENTITY(1,1),

    -- Bölüm adı (boş bırakılamaz ve benzersiz olmalıdır)
    name NVARCHAR(100) NOT NULL,

    -- Bölümün sistemde aktif olup olmadığını belirtir
    -- Varsayılan olarak aktif (1) gelir
    is_active BIT NOT NULL 
        CONSTRAINT DF_departments_is_active DEFAULT 1,

    -- Kaydın oluşturulduğu tarih bilgisi
    -- Varsayılan olarak mevcut tarih ve saat atanır
    created_at DATETIME2(0) NOT NULL 
        CONSTRAINT DF_departments_created_at DEFAULT CURRENT_TIMESTAMP,

    -- Primary Key tanımı
    CONSTRAINT PK_departments_id PRIMARY KEY (id),

    -- Bölüm adlarının tekrar etmemesi için benzersiz kısıtlama
    CONSTRAINT UQ_departments_name UNIQUE (name),

    -- Bölüm adının sadece boşluklardan oluşmasını engelleyen kontrol
    CONSTRAINT CK_departments_name 
        CHECK (LEN(LTRIM(RTRIM(name))) > 0)

);
