USE [WTS]
GO

BEGIN TRY
	DROP FUNCTION [dbo].[ColumnExists]
	DROP FUNCTION [dbo].[TableExists]
END TRY
BEGIN CATCH
	PRINT '';
END CATCH
GO

CREATE function [dbo].[ColumnExists]
(
	@SchemaName VARCHAR(100),
	@TableName VARCHAR(100),
	@ColumnName VARCHAR(100)
)
RETURNS INT

AS

BEGIN
	DECLARE @exists BIT = 0

	IF COL_LENGTH(@SchemaName + '.' + @TableName, @ColumnName) IS NOT NULL	
		SET @exists = 1
	ELSE
		SET @exists = 0

	RETURN @exists
END
GO

CREATE function [dbo].[TableExists]
(
	@SchemaName VARCHAR(100),
	@TableName VARCHAR(100)
)
RETURNS INT

AS

BEGIN
	DECLARE @exists BIT = 0

	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = @SchemaName AND TABLE_NAME = @TableName))
		SET @exists = 1
	ELSE
		SET @exists = 0

	RETURN @exists
END
GO