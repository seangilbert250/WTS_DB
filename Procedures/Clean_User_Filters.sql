USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Clean_User_Filters]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Clean_User_Filters]

GO

CREATE PROCEDURE [dbo].[Clean_User_Filters]
	@SessionID nvarchar(100) = ''
	, @UserName nvarchar(255) = ''
	, @purge bit = 0
	, @deleted bit output
AS
BEGIN
	SET @deleted = 0;

	IF @purge = 1
		AND LEN(@SessionID) > 0 
		AND LEN(@UserName) > 0
		BEGIN
			DELETE FROM User_Filter
			WHERE
				SessionID = @SessionID
				AND UserName = @UserName
			;
		END
	ELSE
		BEGIN
			DELETE FROM User_Filter
			WHERE
				DATEDIFF(HOUR, CreatedDate, getdate()) > 2;
			;
		END;

	SET @deleted = 1;
END;

GO
