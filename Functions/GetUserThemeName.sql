USE WTS
GO

IF OBJECT_ID (N'dbo.GetUserThemeName', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[GetUserThemeName];
GO


CREATE FUNCTION [dbo].[GetUserThemeName]
(
	@username nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN
	DECLARE @count int;
	SET @count = 0;
	DECLARE @theme nvarchar(50);
	SET @theme = 'Ice';

	SELECT @count = COUNT(WTS_RESOURCEID) 
		FROM [WTS_RESOURCE] wr
		WHERE wr.Username = @username;

		IF (ISNULL(@count,0) > 0)
		BEGIN
			SELECT @theme = t.THEME
			FROM
				THEME t
					INNER JOIN [WTS_RESOURCE] wr ON wr.THEMEID = t.THEMEID
				WHERE wr.Username = @username;
		END

	RETURN @theme;
END;

GO
