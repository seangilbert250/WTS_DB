USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[GetRQMTSetName]    Script Date: 8/23/2018 11:07:39 AM ******/
DROP FUNCTION [dbo].[GetRQMTSetName]
GO

/****** Object:  UserDefinedFunction [dbo].[GetRQMTSetName]    Script Date: 8/23/2018 11:07:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetRQMTSetName]
(
	@RQMTSetID INT,
	@IncludeRQMTSetName BIT,
	@IncludeSuite BIT,
	@InclueAssociations BIT,	
	@AppendSetID BIT,
	@ItemSeparator VARCHAR(5)
)
RETURNS NVARCHAR(500)
AS
BEGIN
	DECLARE @name NVARCHAR(500) = ''

	DECLARE @RQMTSetName NVARCHAR(100) = ''
	DECLARE @WTS_SYSTEM_SUITE NVARCHAR(100) = ''
	DECLARE @WTS_SYSTEM NVARCHAR(100) = ''
	DECLARE @WorkArea NVARCHAR(100) = ''
	DECLARE @RQMTType NVARCHAR(100) = ''

	SELECT
		@RQMTSetName = rsn.RQMTSetName,
		@WTS_SYSTEM_SUITE = wss.WTS_SYSTEM_SUITE,
		@WTS_SYSTEM = sys.WTS_SYSTEM,
		@WorkArea = wa.WorkArea,
		@RQMTType = rt.RQMTType
	FROM
		RQMTSet rset
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		JOIN WorkArea wa ON (wa.WorkAreaID = was.WorkAreaID)
		JOIN WTS_SYSTEM sys ON (sys.WTS_SYSTEMID = was.WTS_SYSTEMID)
		JOIN RQMTSetType rst ON (rst.RQMTSetTypeID = rset.RQMTSetTypeID)
		JOIN RQMTSetName rsn ON (rsn.RQMTSetNameID = rst.RQMTSetNameID)
		JOIN RQMTType rt ON (rt.RQMTTypeID = rst.RQMTTypeID)
		JOIN WTS_SYSTEM_SUITE wss ON (wss.WTS_SYSTEM_SUITEID = sys.WTS_SYSTEM_SUITEID)

	IF @IncludeRQMTSetName = 1 SET @name = @name + @RQMTSetName + @ItemSeparator
	IF @IncludeSuite = 1 SET @name = @name + @WTS_SYSTEM_SUITE + @ItemSeparator
	IF @InclueAssociations = 1 set @name = @name + @WTS_SYSTEM + @ItemSeparator + @WorkArea + @ItemSeparator + @RQMTType + @ItemSeparator
	IF @AppendSetID = 1
	BEGIN
		SET @name = LEFT(@NAME, LEN(@name) - LEN(@ItemSeparator)) -- we don't want separator before the setid
		SET @name = @name + ' (' + CONVERT(VARCHAR(100), @RQMTSetID) + ')' + @ItemSeparator
	END

	SET @name = LEFT(@NAME, LEN(@name) - LEN(@ItemSeparator))

	RETURN @name;
END;

GO


