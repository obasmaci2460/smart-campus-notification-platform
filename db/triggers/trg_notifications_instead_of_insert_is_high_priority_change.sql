-- trg_notifications_instead_of_insert_is_high_priority_change trigger’ı,
-- notifications tablosuna yeni kayıt eklenirken
-- SOS olarak işaretlenen bildirimlerin otomatik olarak
-- yüksek öncelikli (is_high_priority = 1) olmasını sağlar

CREATE TRIGGER trg_notifications_instead_of_insert_is_high_priority_change
ON notifications
INSTEAD OF INSERT
AS
BEGIN
	-- Etkilenen satır sayısı mesajlarını kapatır
	SET NOCOUNT ON

	BEGIN TRY
		
		-- Yeni eklenecek bildirimler notifications tablosuna eklenir
		-- Eğer bildirim SOS ise, is_high_priority alanı otomatik olarak 1 yapılır
		INSERT INTO notifications(
			user_id, 
			category_id,
			status_id,
			title,
			description,
			location,
			address,
			is_sos,
			is_high_priority
		)
		SELECT
			user_id, 
			category_id,
			status_id,
			title,
			description,
			location,
			address,
			is_sos,
			CASE 
				WHEN is_sos = 1 THEN 1
				ELSE is_high_priority
			END
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
