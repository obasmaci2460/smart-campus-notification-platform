-- trg_users_after_insert_first_superadmin trigger’ı,
-- users tablosuna eklenen ilk kullanıcının
-- otomatik olarak super_admin rolüne atanmasını sağlar
-- Sistem ilk kurulduğunda yönetici atanması amacıyla kullanılır

CREATE TRIGGER trg_users_after_insert_first_superadmin
ON users
AFTER INSERT
AS
BEGIN
	-- Etkilenen satır sayısı mesajlarını kapatır
	SET NOCOUNT ON

	BEGIN TRY
		-- Eğer users tablosunda sadece 1 kullanıcı varsa
		-- (yani bu eklenen ilk kullanıcıysa)
		-- bu kullanıcı super_admin yapılır
		IF (SELECT COUNT(*) FROM users) = 1
		BEGIN
			UPDATE u 
			SET 
				u.role = 'super_admin',
				u.is_super_admin = 1
			FROM users u 
			INNER JOIN inserted i ON i.id = u.id 
		END
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
