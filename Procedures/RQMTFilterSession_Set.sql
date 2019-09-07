USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTFilterSession_Set]    Script Date: 8/29/2018 12:13:18 PM ******/
DROP PROCEDURE [dbo].[RQMTFilterSession_Set]
GO

/****** Object:  StoredProcedure [dbo].[RQMTFilterSession_Set]    Script Date: 8/29/2018 12:13:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[RQMTFilterSession_Set]
(	
	@SessionID NVARCHAR(100),
	@UserName NVARCHAR(100),
	@FilterTypeID INT = 5,
	@WTS_SYSTEM_SUITE NVARCHAR(255) = NULL,
	@WTS_SYSTEM NVARCHAR(255) = NULL,
	@WorkArea NVARCHAR(255) = NULL,
	@RQMTType NVARCHAR(255) = NULL,
	@RQMTDescriptionType NVARCHAR(255) = NULL,
	@RQMTSetName NVARCHAR(255) = NULL,
	@WorkloadGroup NVARCHAR(255) = NULL,
	@Complexity NVARCHAR(255) = NULL,
	@RQMTStatus NVARCHAR(255) = NULL,
	@RQMTStage NVARCHAR(255) = NULL,
	@Criticality NVARCHAR(255) = NULL,
	@RQMTAccepted NVARCHAR(255) = NULL,
	@saved BIT OUTPUT
)
AS
BEGIN
	SET @saved = 0;
	DECLARE @count INT = 0;
	DECLARE @date DATETIME = GETDATE();

	DELETE FROM User_Filter
	WHERE
		SessionID = @SessionID
		AND UserName = @UserName
		AND FilterTypeID = 5;

	INSERT INTO User_Filter
	SELECT DISTINCT
		@SessionID, 
		@UserName,
		rsrs.RQMTSet_RQMTSystemID AS FilterID,
		5 AS FilterTypeID,
		@date
	FROM
		RQMTSet_RQMTSystem rsrs
		JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
		JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)
		JOIN WTS_SYSTEM wsys ON (wsys.WTS_SYSTEMID = was.WTS_SYSTEMID)
		JOIN WTS_SYSTEM_SUITE wss ON (wss.WTS_SYSTEM_SUITEID = wsys.WTS_SYSTEM_SUITEID)
		JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
		JOIN RQMTType rtype ON (rtype.RQMTTypeID = rsettype.RQMTTypeID)
		JOIN RQMTSetName rsn ON (rsn.RQMTSetNameID = rsettype.RQMTSetNameID)
		JOIN RQMTSystem rsys ON (rsys.RQMTSystemID = rsrs.RQMTSystemID)
		--JOIN WorkloadGroup wg ON (wg.WorkloadGroupID = rset.WorkloadGroupID)
		JOIN RQMTComplexity rcmp ON (rcmp.RQMTComplexityID = rset.RQMTComplexityID)
		LEFT JOIN RQMTSystemRQMTDescription rsysdesc ON (rsysdesc.RQMTSystemID = rsys.RQMTSystemID)
		LEFT JOIN RQMTDescription rqmtdesc ON (rqmtdesc.RQMTDescriptionID = rsysdesc.RQMTDescriptionID)
		LEFT JOIN RQMTAttribute rattrstatus ON (rattrstatus.RQMTAttributeID = rsys.RQMTStatusID)
		LEFT JOIN RQMTAttribute rattrstage ON (rattrstage.RQMTAttributeID = rsys.RQMTStageID)
		LEFT JOIN RQMTAttribute rattrcrit ON (rattrcrit.RQMTAttributeID = rsys.CriticalityID)
	WHERE
		(ISNULL(@WTS_SYSTEM,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), was.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)		
		AND (ISNULL(@WTS_SYSTEM_SUITE,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), wss.WTS_SYSTEM_SUITEID) + ',', ',' + @WTS_SYSTEM_SUITE + ',') > 0)
		AND (ISNULL(@WorkArea,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), was.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)
		AND (ISNULL(@RQMTType,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rtype.RQMTTypeID) + ',', ',' + @RQMTType + ',') > 0)
		AND (ISNULL(@RQMTDescriptionType,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rqmtdesc.RQMTDescriptionTypeID) + ',', ',' + @RQMTDescriptionType + ',') > 0)	
		AND (ISNULL(@RQMTSetName,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rsn.RQMTSetNameID) + ',', ',' + @RQMTSetName + ',') > 0)	
		--AND (ISNULL(@WorkloadGroup,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rset.WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0)
		AND (ISNULL(@Complexity,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rset.RQMTComplexityID) + ',', ',' + @Complexity + ',') > 0)
		AND (ISNULL(@RQMTStatus,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rsys.RQMTStatusID) + ',', ',' + @RQMTStatus + ',') > 0)
		AND (ISNULL(@RQMTStage,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rsys.RQMTStageID) + ',', ',' + @RQMTStage + ',') > 0)
		AND (ISNULL(@Criticality,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rsys.CriticalityID) + ',', ',' + @Criticality + ',') > 0)
		AND (ISNULL(@RQMTAccepted,'') = '' OR CHARINDEX(',' + CONVERT(NVARCHAR(10), rsys.RQMTAccepted) + ',', ',' + @RQMTAccepted + ',') > 0)

	SELECT @count = COUNT(*) 
	FROM USER_FILTER uf
	WHERE 
		uf.SessionID = @SessionID
		AND uf.UserName = @UserName
		AND uf.FilterTypeID = 5;

	IF ISNULL(@count,0) > 0
		SET @saved = 1;
END
GO


