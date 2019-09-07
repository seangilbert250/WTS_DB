USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PasswordResetRequest_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PasswordResetRequest_Add]

GO

CREATE PROCEDURE [dbo].[PasswordResetRequest_Add]
	@UserID UNIQUEIDENTIFIER,
	@requestDateTicks BIGINT,
	@resetcode UNIQUEIDENTIFIER output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT @resetcode = NEWID();
	
	BEGIN TRY
		INSERT INTO PASSWORDRESETREQUEST(
			resetcode,
			requestDateTicks,
			userId
		)
		VALUES(
			@resetcode,
			@requestDateTicks,
			@UserID
		);
	END TRY
	BEGIN CATCH
		SELECT @resetcode = cast(cast(0 as binary) as uniqueidentifier);
	END CATCH;
END;

GO
