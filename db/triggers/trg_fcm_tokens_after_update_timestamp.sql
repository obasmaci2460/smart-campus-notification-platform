-- trg_fcm_tokens_after_update_timestamp trigger’ı,
-- fcm_tokens tablosunda bir kayıt güncellendiğinde
-- updated_at alanının otomatik olarak güncellenmesini sağlar

CREATE TRIGGER trg_fcm_tokens_after_update_timestamp
ON fcm_tokens
AFTER UPDATE
AS
BEGIN
	-- Etkilenen satır sayısı mesajlarını kapatır
	SET NOCOUNT ON

	BEGIN TRY
		-- Güncellenen kayıtların updated_at alanını
		-- mevcut tarih ve saat ile otomatik olarak günceller
		UPDATE f
		SET f.updated_at = CURRENT_TIMESTAMP
		FROM fcm_tokens f
		INNER JOIN inserted i ON i.id = f.id  
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
