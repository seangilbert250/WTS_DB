USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[GetErrorInfo]    Script Date: 3/16/2018 1:08:21 PM ******/
DROP FUNCTION [dbo].[GetErrorInfo]
GO

/****** Object:  UserDefinedFunction [dbo].[GetErrorInfo]    Script Date: 3/16/2018 1:08:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetErrorInfo]  
()
RETURNS VARCHAR(MAX)
AS
BEGIN
	RETURN '[ERROR NUMBER: ' + CONVERT(VARCHAR(200), ERROR_NUMBER()) + ', LINE: ' + CONVERT(VARCHAR(5), ERROR_LINE()) + '] ' + ERROR_MESSAGE()
END

GO


