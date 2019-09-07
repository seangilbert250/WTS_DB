USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PasswordResetRequest_Clear]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PasswordResetRequest_Clear]

GO

CREATE PROCEDURE [dbo].[PasswordResetRequest_Clear]
	@UserID UNIQUEIDENTIFIER,
	@cleared BIT output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @count int = 0;;

	SELECT @cleared = 0;
	
	BEGIN TRY
		SELECT @count = COUNT(1) FROM PASSWORDRESETREQUEST
		WHERE
			userId = @UserID;

		IF ISNULL(@count,0) > 0
			BEGIN
				DELETE FROM PASSWORDRESETREQUEST
				WHERE
					userId = @UserID;

				SELECT @cleared = 1;
			END
		ELSE
			BEGIN
				SET @cleared = 1;
			END

	END TRY
	BEGIN CATCH
		SELECT @cleared = 0;
	END CATCH;
END;

GO
