USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PasswordResetRequest_Load]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PasswordResetRequest_Load]

GO

CREATE PROCEDURE [dbo].[PasswordResetRequest_Load]
	@resetcode UNIQUEIDENTIFIER,
	@userId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT
		prr.resetcode
		, prr.userId
		, prr.requestDateTicks
		, prr.expired
	FROM
		PASSWORDRESETREQUEST prr
	WHERE
		prr.resetcode = @resetcode
		AND prr.userId = @userId;
END;

GO
