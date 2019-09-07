USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Assoc_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Assoc_Get]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AOREstimation_Assoc_Get]
	@AOREstimation_AORReleaseID INT = 0,
	@IncludeArchive INT = 0
AS
BEGIN
	

	SELECT Main.AORID
	, Left(Main.Deployments, LEN(Main.Deployments)-1) as Deployments
	INTO #DEPLOYMENT_TEMP 
	FROM (
			SELECT b.AORID
					, b.Deployments
			FROM (
				SELECT DISTINCT AORID
							, (
								SELECT a.Deployment + ', ' as [text()]
								FROM (
										SELECT AR2.AORID 
												, PV.ProductVersion + '.' + RS.ReleaseScheduleDeliverable AS Deployment
										FROM AORRelease AR2
										LEFT OUTER JOIN AORReleaseDeliverable ARD
										ON AR2.AORReleaseID = ARD.AORReleaseID
										LEFT OUTER JOIN ReleaseSchedule RS
										ON ARD.DeliverableID = RS.ReleaseScheduleID
										LEFT OUTER JOIN ProductVersion PV
										ON RS.ProductVersionID = PV.ProductVersionID
									) a
								WHERE a.AORID = A3.AORID
								ORDER BY a.AORID
								FOR XML PATH ('')
								) AS [Deployments]
				FROM AOR A3
			) b
			WHERE len(b.Deployments) > 0
	) [Main] 
	;

	SELECT A.AORID AS "AOR #"
				, A.AORName AS "AOR Name"
				, DT.Deployments AS "Deployment(s)"
				, COUNT(ARR.WTS_RESOURCEID) / COUNT(DISTINCT AR.AORReleaseID) AS "Avg. Resources"
				, AEAA.Notes
				, ISNULL(AEAA.[Primary],'') AS "Primary"
				, AEAA.AOREstimation_AORAssocID
		FROM AOR A
		LEFT OUTER JOIN AORRelease AR
		ON A.AORID = AR.AORID
		LEFT OUTER JOIN AORReleaseResource ARR
		ON AR.AORReleaseID = ARR.AORReleaseID
		LEFT OUTER JOIN #DEPLOYMENT_TEMP DT
		ON A.AORID = DT.AORID
		LEFT OUTER JOIN AOREstimation_AORAssoc AEAA
		ON A.AORID = AEAA.AORID
		WHERE AEAA.AOREstimation_AORReleaseID = @AOREstimation_AORReleaseID
		GROUP BY A.AORID
				, A.AORName
				, DT.Deployments
				, AEAA.Notes
				, AEAA.[Primary]
				, AEAA.AOREstimation_AORAssocID
	
	DROP TABLE #DEPLOYMENT_TEMP;

END;

GO