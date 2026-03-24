-- categories tablosu, sistemde kullanılan bildirim kategorilerini tutmak için oluşturulmuştur
-- Her kategori için sistem adı, ekranda görünen adı, ikon, renk ve aktiflik bilgisi saklanır

CREATE TABLE categories (

    -- Kategori için benzersiz kimlik numarası
    id TINYINT IDENTITY(1,1),

    -- Kategorinin sistemde kullanılan kısa adı
    name VARCHAR(20) NOT NULL,

    -- Kategorinin kullanıcı arayüzünde görünen adı
    display_name NVARCHAR(50) NOT NULL, 

    -- Kategoriye ait ikon bilgisi
    icon VARCHAR(30) NOT NULL,

    -- Kategorinin arayüzde kullanılacak renk kodu (#RRGGBB formatında)
    color_hex CHAR(7) NOT NULL,

    -- Kategorinin aktif olup olmadığını belirtir
    -- Varsayılan olarak aktif (1) gelir
    is_active BIT NOT NULL 
        CONSTRAINT DF_categories_is_active DEFAULT 1,

    -- Primary Key tanımı
    CONSTRAINT PK_categories_id PRIMARY KEY (id),

    -- Kategori adlarının tekrar etmemesi için benzersiz kısıtlama
    CONSTRAINT UQ_categories_name UNIQUE (name),

    -- Sadece belirlenen kategori adlarının girilmesine izin verilir
    CONSTRAINT CK_categories_name 
        CHECK (name IN ('security','maintenance','cleaning','infrastructure','other')),

    -- Renk kodunun geçerli bir HEX formatında olmasını sağlar
    CONSTRAINT CK_categories_color_hex 
        CHECK (color_hex LIKE '#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]'),

    -- Ekranda görünen adın boş veya sadece boşluk olmamasını sağlar
    CONSTRAINT CK_categories_display_name 
        CHECK (LEN(LTRIM(RTRIM(display_name))) > 0)

);
