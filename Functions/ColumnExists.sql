USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[ColumnExists]    Script Date: 1/31/2018 11:11:35 AM ******/
DROP FUNCTION [dbo].[ColumnExists]
GO

/****** Object:  UserDefinedFunction [dbo].[ColumnExists]    Script Date: 1/31/2018 11:11:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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


