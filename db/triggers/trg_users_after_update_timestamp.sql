CREATE TRIGGER trg_users_after_update_timestamp
ON users
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		UPDATE u
		SET u.updated_at=CURRENT_TIMESTAMP FROM users u INNER JOIN inserted i ON i.id=u.id  
	END TRY
	BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
			DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
			DECLARE @ErrorState INT = ERROR_STATE()

			RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

			IF @@TRANCOUNT>0
				ROLLBACK TRANSACTION
	END CATCH
END
