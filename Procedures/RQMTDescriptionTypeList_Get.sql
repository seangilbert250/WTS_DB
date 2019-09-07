use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[RQMTDescriptionTypeList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[RQMTDescriptionTypeList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

CREATE procedure [dbo].[RQMTDescriptionTypeList_Get]
	@IncludeArchive INT = 0
AS
begin

		SELECT * FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			'' AS A
			, 0 AS RQMTDescriptionTypeID
			, '' AS RQMTDescriptionType
			, '' AS [Description]
			--, 0 AS Size_Count
			--, NULL AS SORT_ORDER
			, 0 AS Sort
			, 0 AS ARCHIVE
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL
		
		SELECT
			'' AS A
			,RQMTDESCTYPE.RQMTDescriptionTypeID
			,RQMTDESCTYPE.RQMTDescriptionType
			,RQMTDESCTYPE.[Description]
			,RQMTDESCTYPE.Sort
			,RQMTDESCTYPE.Archive
			, '' as X
			, RQMTDESCTYPE.CREATEDBY
			, convert(varchar, RQMTDESCTYPE.CREATEDDATE, 110) AS CREATEDDATE
			, RQMTDESCTYPE.UPDATEDBY
			, convert(varchar, RQMTDESCTYPE.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			RQMTDescriptionType RQMTDESCTYPE
		WHERE 
			(ISNULL(@IncludeArchive,1) = 1 OR RQMTDESCTYPE.Archive = @IncludeArchive)
	) RQMTDESCTYPE
	--ORDER BY el.SORT_ORDER ASC, UPPER(el.EffortArea) ASC
	ORDER BY Sort ASC
end;

GO
