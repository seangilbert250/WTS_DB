USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Clean_User_SessionViews]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Clean_User_SessionViews]

GO

CREATE PROCEDURE [dbo].[Clean_User_SessionViews]
	@SessionID nvarchar(100) = ''
	, @WTS_ResourceID int = null
	, @purge bit = 0
	, @deleted bit output
AS
BEGIN
	SET @deleted = 0;

	IF @purge = 1
		AND LEN(@SessionID) > 0 
		AND ISNULL(@WTS_ResourceID,0) > 0
		BEGIN
			DELETE FROM GridView
			WHERE
				SessionID = @SessionID
				AND WTS_RESOURCEID = @WTS_RESOURCEID;
		END
	ELSE
		BEGIN
			DELETE FROM GridView
			WHERE
				(@SessionID IS NOT NULL AND LEN(@SessionID) > 0)
				AND DATEDIFF(HOUR, CREATEDDATE, getdate()) > 2;
		END;

	SET @deleted = 1;

END;

GO
