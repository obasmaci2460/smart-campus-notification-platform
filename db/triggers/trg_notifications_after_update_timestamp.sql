-- trg_notifications_after_update_timestamp trigger’ı,
-- notifications tablosunda bir kayıt güncellendiğinde
-- updated_at alanının otomatik olarak güncellenmesini sağlar

CREATE TRIGGER trg_notifications_after_update_timestamp
ON notifications
AFTER UPDATE
AS
BEGIN
	-- Etkilenen satır sayısı mesajlarını kapatır
	SET NOCOUNT ON

	BEGIN TRY
		-- Güncellenen kayıtların updated_at alanını
		-- mevcut tarih ve saat ile otomatik olarak günceller
		UPDATE n
		SET n.updated_at = CURRENT_TIMESTAMP
		FROM notifications n
		INNER JOIN inserted i ON i.id = n.id  
	END TRY
	BEGIN CATCH
			-- Hata mesajı, seviyesi ve durumu alınır
			DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
			DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
			DECLARE @ErrorState INT = ERROR_STATE()

			-- Oluşan hata tekrar fırlatılır
			RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)

			-- Aktif bir transaction varsa geri alınır
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
	END CATCH
END
