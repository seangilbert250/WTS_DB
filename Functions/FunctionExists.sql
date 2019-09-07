USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[FunctionExists]    Script Date: 5/7/2018 9:31:59 AM ******/
DROP FUNCTION [dbo].[FunctionExists]
GO

/****** Object:  UserDefinedFunction [dbo].[FunctionExists]    Script Date: 5/7/2018 9:31:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[FunctionExists]
(
	@SchemaName VARCHAR(100),
	@FunctionName VARCHAR(100)
)
RETURNS INT

AS

BEGIN
	DECLARE @exists BIT = 0

	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = @SchemaName AND ROUTINE_NAME = @FunctionName AND ROUTINE_TYPE = 'FUNCTION'))
		SET @exists = 1
	ELSE
		SET @exists = 0

	RETURN @exists
END
GO


