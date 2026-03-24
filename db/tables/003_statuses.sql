-- statuses tablosu, bildirimlerin sistemde alabileceği durumları tutmak için oluşturulmuştur
-- Her durum için sistem adı, ekranda görünen adı, renk bilgisi ve aktiflik durumu saklanır

CREATE TABLE statuses (

    -- Durum için benzersiz kimlik numarası
    id TINYINT NOT NULL IDENTITY(1,1),

    -- Durumun sistemde kullanılan kısa adı
    name VARCHAR(20) NOT NULL,

    -- Durumun kullanıcı arayüzünde görünen adı
    display_name NVARCHAR(20) NOT NULL,

    -- Duruma ait arayüz rengi (#RRGGBB formatında)
    color_hex CHAR(7) NOT NULL,

    -- Durumun aktif olup olmadığını belirtir
    -- Varsayılan olarak aktif (1) gelir
    is_active BIT NOT NULL 
        CONSTRAINT DF_statuses_is_active DEFAULT 1,

    -- Primary Key tanımı
    CONSTRAINT PK_statuses_id PRIMARY KEY (id),

    -- Durum adlarının tekrar etmemesi için benzersiz kısıtlama
    CONSTRAINT UQ_statuses_name UNIQUE (name),

    -- Sadece belirlenen durum adlarının girilmesine izin verilir
    CONSTRAINT CK_statuses_name 
        CHECK (name IN ('open','in_review','resolved','spam')),

    -- Renk kodunun geçerli bir HEX formatında olmasını sağlar
    CONSTRAINT CK_statuses_color_hex 
        CHECK (color_hex LIKE '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]'),

    -- Ekranda görünen adın boş veya sadece boşluk olmamasını engeller
    CONSTRAINT CK_statuses_display_name 
        CHECK (LEN(LTRIM(RTRIM(display_name))) > 0)

);
