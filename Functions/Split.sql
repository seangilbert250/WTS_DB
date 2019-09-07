USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 8/6/2018 2:33:57 PM ******/
DROP FUNCTION [dbo].[Split]
GO

/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 8/6/2018 2:33:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[Split]
(
	@RowData nvarchar(MAX),
	@SplitOn nvarchar(100)
)
RETURNS @returntable TABLE
(
	Data NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @Counter int;
	SET @Counter = 1;

	WHILE (Charindex(@SplitOn,@RowData)>0)
	BEGIN
		INSERT INTO @returntable (data)
			SELECT Data = ltrim(rtrim(Substring(@RowData,1,Charindex(@SplitOn,@RowData)-1)))
			SET @RowData = Substring(@RowData,Charindex(@SplitOn,@RowData)+len(@SplitOn),len(@RowData))
			SET @Counter = @Counter + 1 
	END;

	INSERT INTO @returntable (data)
		SELECT Data = ltrim(rtrim(@RowData))
		
	Return;
END;

GO


