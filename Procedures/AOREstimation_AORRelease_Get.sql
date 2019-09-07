USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_AORRelease_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_AORRelease_Get]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AOREstimation_AORRelease_Get]
	@AORReleaseID INT = 0,
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT --a.X
		   a.AOREstimation_AORReleaseID
		 --, a.AORReleaseID
		 , a.AOREstimationID
		 , a.AOREstimationName
		 , a.Weight
		 , a.PriorityID
		 , a.PRIORITY
		 , a.Details
		 , a.MitigationPlan
		 --, a.CreatedBy
		 , a.UpdatedBy
		 , a.UpdatedDate
		 --, a.Y
	FROM (
		SELECT --'' as X
			   NULL AS AOREstimation_AORReleaseID
			 --, NULL AS AORReleaseID
			  , ae.AOREstimationID
			  , ae.AOREstimationName
			  , NULL AS Weight
			  , NULL AS PriorityID
			  , NULL AS PRIORITY
			  , NULL AS Details
			  , NULL AS MitigationPlan
			 --, isnull(Archive,0) as Archive
			 --, NULL AS CreatedBy
			 , NULL AS UpdatedBy
			 , NULL as UpdatedDate
			 --, '' as Y
		FROM [dbo].[AOREstimation] ae
		WHERE NOT EXISTS (
			SELECT 1
			FROM AOREstimation_AORRelease aear
			WHERE ae.AOREstimationID = aear.AOREstimationID
			AND aear.AORReleaseID = @AORReleaseID
			)
		UNION
		SELECT --'' as X
			   aear.AOREstimation_AORReleaseID
			 --, aear.AORReleaseID
			 , aear.AOREstimationID
			 , ae.AOREstimationName
			 , aear.Weight
			 , p.PriorityID
			 , p.PRIORITY
			 , aear.Details
			 , aear.MitigationPlan
			 --, isnull(Archive,0) as Archive
			 --, CONCAT(aear.CreatedBy, ': ',  LEFT(CONVERT(varchar, aear.CreatedDate, 120),10)) as CreatedBy
			 , aear.UpdatedBy
			 , aear.UpdatedDate
			 --, '' as Y
		FROM [dbo].[AOREstimation] ae
		LEFT OUTER JOIN [dbo].[AOREstimation_AORRelease] aear
		on ae.AOREstimationID = aear.AOREstimationID
		LEFT OUTER JOIN [dbo].[PRIORITY] p
		on aear.PriorityID = p.PRIORITYID
		inner join [dbo].[PRIORITYTYPE] pt
		on p.PRIORITYTYPEID = pt.PRIORITYTYPEID
		WHERE aear.AORReleaseID = @AORReleaseID
		AND isnull(aear.Archive,0) = 0
		AND isnull(pt.PRIORITYTYPE, '') = 'AOR Estimation'
	) a
	ORDER BY a.AOREstimationName
	;
END;

GO
