-- trg_users_after_insert_create_preferences trigger’ı,
-- users tablosuna yeni bir kullanıcı eklendiğinde
-- o kullanıcı için varsayılan bildirim tercihlerini
-- otomatik olarak oluşturmak için kullanılır

CREATE TRIGGER trg_users_after_insert_create_preferences
ON users
AFTER INSERT
AS
BEGIN
	-- Etkilenen satır sayısı mesajlarını kapatır
	SET NOCOUNT ON

	BEGIN TRY
		-- Yeni eklenen kullanıcılar için
		-- notification_preferences tablosuna varsayılan (aktif) tercihler eklenir
		INSERT INTO notification_preferences(
			user_id,
			notify_security,
			notify_maintenance,
			notify_cleaning,
			notify_infrastructure,
			notify_other
		)
		SELECT
			id,
			1,
			1,
			1,
			1,
			1
		FROM inserted
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
