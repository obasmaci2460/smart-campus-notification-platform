-- Bu stored procedure, bir bildirimin durumunu güncellemek için kullanılır
-- Aynı zamanda yapılan durum değişikliği status_history tablosuna kaydedilir
-- İşlem sırasında hata oluşursa tüm değişiklikler geri alınır (transaction kullanımı)

CREATE PROCEDURE sp_update_notification_status
    @notification_id INT,      -- Durumu güncellenecek bildirimin ID'si
    @new_status_id TINYINT,     -- Bildirimin alacağı yeni durum
    @admin_user_id INT         -- İşlemi yapan admin kullanıcının ID'si
AS
BEGIN
    SET NOCOUNT ON; -- Etkilenen satır sayısı mesajlarını kapatır
    
    DECLARE @old_status_id TINYINT;          -- Bildirimin eski durumu
    DECLARE @user_id_binary VARBINARY(128);  -- CONTEXT_INFO için kullanılacak binary veri
    DECLARE @padding VARBINARY(124);         

    BEGIN TRY
        BEGIN TRANSACTION; -- Tüm işlemler tek bir transaction içinde yapılır
        
        -- Bildirimin mevcut (eski) durumunu al
        SELECT @old_status_id = status_id
        FROM notifications
        WHERE id = @notification_id AND deleted_at IS NULL;
        
        -- Bildirim bulunamadıysa hata ver
        IF @old_status_id IS NULL
        BEGIN
            RAISERROR('Notification not found', 16, 1);
            RETURN;
        END
        
        -- Bildirim zaten çözüldüyse tekrar çözülmesine izin verme
        IF @old_status_id = 3
        BEGIN
            RAISERROR('Notification already resolved', 16, 1);
            RETURN;
        END
        
        -- Trigger veya audit mekanizmalarında kullanılmak üzere
        -- admin kullanıcının ID'si CONTEXT_INFO içine yazılır
        SET @padding = CAST(REPLICATE(CHAR(0), 124) AS VARBINARY(124));
        SET @user_id_binary = CAST(@admin_user_id AS VARBINARY(4)) + @padding;
        SET CONTEXT_INFO @user_id_binary;
        
        -- Bildirimin durumu güncellenir
        -- Eğer yeni durum "resolved" ise çözülme tarihi ve çözen kullanıcı da set edilir
        UPDATE notifications
        SET 
            status_id = @new_status_id,
            resolved_at = CASE 
                            WHEN @new_status_id = 3 THEN CURRENT_TIMESTAMP 
                            ELSE resolved_at 
                          END,
            resolved_by_user_id = CASE 
                                    WHEN @new_status_id = 3 THEN @admin_user_id 
                                    ELSE resolved_by_user_id 
                                  END
        WHERE id = @notification_id;
        
        -- Yapılan durum değişikliği status_history tablosuna kaydedilir
        INSERT INTO status_history (
            notification_id, 
            old_status_id, 
            new_status_id,
            changed_by_user_id, 
            changed_at
        )
        VALUES (
            @notification_id, 
            @old_status_id, 
            @new_status_id,
            @admin_user_id, 
            CURRENT_TIMESTAMP
        );
        
        COMMIT TRANSACTION; -- Tüm işlemler başarıyla tamamlandı
        
        -- CONTEXT_INFO temizlenir
        SET CONTEXT_INFO 0x0;
        
    END TRY
    BEGIN CATCH
        -- Hata oluşursa yapılan işlemler geri alınır
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Hata mesajı tekrar fırlatılır
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO
