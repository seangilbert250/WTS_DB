USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTFilterData_Get]    Script Date: 8/29/2018 12:10:43 PM ******/
DROP PROCEDURE [dbo].[RQMTFilterData_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTFilterData_Get]    Script Date: 8/29/2018 12:10:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[RQMTFilterData_Get]
(
	@FilterName NVARCHAR(255),
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
	@RQMTAccepted NVARCHAR(255) = NULL
)
AS
BEGIN
	SELECT * FROM
	(
		SELECT DISTINCT 
			CASE @FilterName
				WHEN 'System Suite' THEN wss.WTS_SYSTEM_SUITEID
				WHEN 'System(Task)' THEN was.WTS_SYSTEMID
				WHEN 'Work Area' THEN was.WorkAreaID
				WHEN 'RQMTType' THEN rtype.RQMTTypeID
				WHEN 'RQMTDescriptionType' THEN rqmtdesc.RQMTDescriptionTypeID
				WHEN 'RQMTSetName' THEN rsn.RQMTSetNameID
				--WHEN 'WorkloadGroup' THEN rset.WorkloadGroupID
				WHEN 'Complexity' THEN rset.RQMTComplexityID
				WHEN 'RQMTStatus' THEN rattrstatus.RQMTAttributeID
				WHEN 'RQMTStage' THEN rattrstage.RQMTAttributeID
				WHEN 'Criticality' THEN rattrcrit.RQMTAttributeID
				WHEN 'RQMTAccepted' THEN rsys.RQMTAccepted
			END AS FilterID,
			CASE @FilterName
				WHEN 'System Suite' THEN wss.WTS_SYSTEM_SUITE
				WHEN 'System(Task)' THEN wsys.WTS_SYSTEM				
				WHEN 'Work Area' THEN wa.WorkArea
				WHEN 'RQMTType' THEN rtype.RQMTType
				WHEN 'RQMTDescriptionType' THEN rdesctype.RQMTDescriptionType
				WHEN 'RQMTSetName' THEN rsn.RQMTSetName
				--WHEN 'WorkloadGroup' THEN wg.WorkloadGroup
				WHEN 'Complexity' THEN rcmp.RQMTComplexity
				WHEN 'RQMTStatus' THEN rattrstatus.RQMTAttribute
				WHEN 'RQMTStage' THEN rattrstage.RQMTAttribute
				WHEN 'Criticality' THEN rattrcrit.RQMTAttribute
				WHEN 'RQMTAccepted' THEN (CASE WHEN rsys.RQMTAccepted = 1 THEN 'Yes' ELSE 'No' END)
			END AS FilterValue
		FROM 
			RQMTSet_RQMTSystem rsrs
			JOIN RQMTSet rset ON (rset.RQMTSetID = rsrs.RQMTSetID)
			JOIN WorkArea_System was ON (was.WorkArea_SystemId = rset.WorkArea_SystemId)			
			JOIN WTS_SYSTEM wsys ON (wsys.WTS_SYSTEMID = was.WTS_SYSTEMID)
			JOIN WTS_SYSTEM_SUITE wss ON (wss.WTS_SYSTEM_SUITEID = wsys.WTS_SYSTEM_SUITEID)
			JOIN WorkArea wa ON (wa.WorkAreaID = was.WorkAreaID)
			JOIN RQMTSetType rsettype ON (rsettype.RQMTSetTypeID = rset.RQMTSetTypeID)
			JOIN RQMTType rtype ON (rtype.RQMTTypeID = rsettype.RQMTTypeID)
			JOIN RQMTSetName rsn ON (rsn.RQMTSetNameID = rsettype.RQMTSetNameID)
			JOIN RQMTSystem rsys ON (rsys.RQMTSystemID = rsrs.RQMTSystemID)
			--JOIN WorkloadGroup wg ON (wg.WorkloadGroupID = rset.WorkloadGroupID)
			JOIN RQMTComplexity rcmp ON (rcmp.RQMTComplexityID = rset.RQMTComplexityID)
			LEFT JOIN RQMTSystemRQMTDescription rsysdesc ON (rsysdesc.RQMTSystemID = rsys.RQMTSystemID)
			LEFT JOIN RQMTDescription rqmtdesc ON (rqmtdesc.RQMTDescriptionID = rsysdesc.RQMTDescriptionID)
			LEFT JOIN RQMTDescriptionType rdesctype ON (rdesctype.RQMTDescriptionTypeID = rqmtdesc.RQMTDescriptionTypeID)
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
	) t
	WHERE t.FilterID IS NOT NULL
	ORDER BY t.FilterValue
END
GO


