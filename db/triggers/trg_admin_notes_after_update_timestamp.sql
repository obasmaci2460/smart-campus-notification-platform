-- trg_admin_notes_after_update_timestamp trigger’ı,
-- admin_notes tablosunda bir kayıt güncellendiğinde
-- updated_at alanının otomatik olarak güncellenmesini sağlar

CREATE TRIGGER trg_admin_notes_after_update_timestamp
ON admin_notes
AFTER UPDATE
AS
BEGIN
	-- Etkilenen satır sayısı mesajlarını kapatır
	SET NOCOUNT ON

	BEGIN TRY
		-- Güncellenen kayıtların updated_at alanını
		-- mevcut tarih ve saat ile otomatik olarak günceller
		UPDATE a
		SET a.updated_at = CURRENT_TIMESTAMP
		FROM admin_notes a
		INNER JOIN inserted i ON i.id = a.id  
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
