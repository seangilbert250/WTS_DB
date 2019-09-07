USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[ProcedureExists]    Script Date: 5/7/2018 9:31:41 AM ******/
DROP FUNCTION [dbo].[ProcedureExists]
GO

/****** Object:  UserDefinedFunction [dbo].[ProcedureExists]    Script Date: 5/7/2018 9:31:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[ProcedureExists]
(
	@SchemaName VARCHAR(100),
	@ProcedureName VARCHAR(100)
)
RETURNS INT

AS

BEGIN
	DECLARE @exists BIT = 0

	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = @SchemaName AND ROUTINE_NAME = @ProcedureName AND ROUTINE_TYPE = 'PROCEDURE'))
		SET @exists = 1
	ELSE
		SET @exists = 0

	RETURN @exists
END
GO


