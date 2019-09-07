USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[TableExists]    Script Date: 1/31/2018 11:12:01 AM ******/
DROP FUNCTION [dbo].[TableExists]
GO

/****** Object:  UserDefinedFunction [dbo].[TableExists]    Script Date: 1/31/2018 11:12:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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


