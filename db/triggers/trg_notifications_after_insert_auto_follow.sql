-- trg_notifications_after_insert_auto_follow trigger’ı,
-- notifications tablosuna yeni bir bildirim eklendiğinde
-- bildirimi oluşturan kullanıcının otomatik olarak
-- o bildirimi takip etmesini sağlar

CREATE TRIGGER trg_notifications_after_insert_auto_follow	
ON notifications
AFTER INSERT
AS
BEGIN
	-- Etkilenen satır sayısı mesajlarını kapatır
	SET NOCOUNT ON

	BEGIN TRY
		-- Yeni eklenen bildirimler için
		-- bildirimi oluşturan kullanıcı notification_followers tablosuna eklenir
		INSERT INTO notification_followers(
			notification_id,
			user_id,
			followed_at
		)
		SELECT
			id,
			user_id,
			CURRENT_TIMESTAMP
		FROM
			inserted
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
