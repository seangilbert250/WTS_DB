
USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDDTDR_PhaseList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PDDTDR_PhaseList_Get]

GO
USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[PDDTDR_PhaseList_Get]    Script Date: 6/9/2016 10:00:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PDDTDR_PhaseList_Get]
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS PDDTDR_PhaseID
			, '' AS PDDTDR_Phase
			, '' AS [DESCRIPTION]
			, 0 AS WorkType_Count
			, 0 AS WorkItem_Count
			, NULL AS SORT_ORDER
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
			, '' AS WorkActivityGroupIDs
		UNION ALL
		
		SELECT
			p.PDDTDR_PhaseID
			, p.PDDTDR_Phase
			, p.[DESCRIPTION]
			, (SELECT COUNT(WorkTypeID) 
				FROM WorkType_PHASE wtp 
				WHERE wtp.PDDTDR_PHASEID = p.PDDTDR_PHASEID) AS WorkType_Count
			, (SELECT COUNT(WORKITEMID) 
				FROM WORKITEM wi
				WHERE wi.PDDTDR_PHASEID = p.PDDTDR_PHASEID) AS WorkItem_Count
			, p.SORT_ORDER
			, p.ARCHIVE
			, '' as X
			, p.CREATEDBY
			, convert(varchar, p.CREATEDDATE, 110) AS CREATEDDATE
			, p.UPDATEDBY
			, convert(varchar, p.UPDATEDDATE, 110) AS UPDATEDDATE
			, stuff((select distinct ',' + convert(nvarchar(10), agp.WorkActivityGroupID)
				from WorkActivityGroup_Phase agp
				where agp.PDDTDR_PHASEID = p.PDDTDR_PHASEID
			for xml path(''), type
			).value('.', 'nvarchar(50)'),1,1,'') WorkActivityGroupIDs
		FROM
			PDDTDR_Phase p
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR p.Archive = @IncludeArchive)
	) p
	ORDER BY p.SORT_ORDER ASC, UPPER(p.PDDTDR_Phase) ASC
END;

