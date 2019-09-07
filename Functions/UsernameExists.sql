USE WTS
GO

IF OBJECT_ID (N'dbo.UsernameExists', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[UsernameExists];
GO


CREATE FUNCTION [dbo].[UsernameExists]
(
	@username nvarchar(50)
)
RETURNS bit
AS
BEGIN
	DECLARE @count int;
	SET @count = 0;
	DECLARE @isExisting bit;
	SET @isExisting = 0;

	SELECT @count = COUNT(WTS_RESOURCEID) 
		FROM [WTS_RESOURCE] WR
		WHERE WR.Username = @username

		IF (ISNULL(@count,0) > 0)
			SET @isExisting = 1;
		ELSE
			SET @isExisting = 0;

	RETURN @isExisting;
END;

GO