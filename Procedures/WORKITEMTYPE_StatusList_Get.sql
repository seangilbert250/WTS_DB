﻿USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_StatusList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_StatusList_Get]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_StatusList_Get]
	@WORKITEMTYPEID int = null
	, @STATUSID int = null
AS
BEGIN

		SELECT * FROM (
			--Add empty header row, used to make sure header is always created and row for cloning to create new records
			SELECT
				0 AS WORKITEMTYPE_StatusID
				, 0 AS WORKITEMTYPEID
				, '' AS WORKITEMTYPE
				, 0 AS STATUSID
				, '' AS STATUS
				, '' AS [DESCRIPTION]
				, 0 AS ARCHIVE
				, '' AS X
				, '' AS CREATEDBY
				, '' AS CREATEDDATE
				, '' AS UPDATEDBY
				, '' AS UPDATEDDATE
				,0 AS SortOrder
			UNION ALL

			SELECT
				WITS.WORKITEMTYPE_StatusID
				, WIT.WORKITEMTYPEID
				, WIT.WORKITEMTYPE
				, S.STATUSID
				, S.STATUS
				, S.[DESCRIPTION]
				, WITS.ARCHIVE
				, '' as X
				, WITS.CREATEDBY
				, convert(varchar, WITS.CREATEDDATE, 110) AS CREATEDDATE
				, WITS.UPDATEDBY
				, convert(varchar, WITS.UPDATEDDATE, 110) AS UPDATEDDATE
				, WITS.SORT_ORDER
			FROM
				WORKITEMTYPE_Status WITS
					LEFT JOIN WORKITEMTYPE WIT ON WITS.WORKITEMTYPEID = WIT.WORKITEMTYPEID
					LEFT JOIN STATUS S ON WITS.STATUSID = S.STATUSID
			WHERE  
				(ISNULL(@WORKITEMTYPEID,0) = 0 OR WIT.WORKITEMTYPEID = @WORKITEMTYPEID)
				AND (ISNULL(@STATUSID,0) = 0 OR S.STATUSID = @STATUSID)
				
		) WITS
		ORDER BY WITS.STATUS ASC;
END;

