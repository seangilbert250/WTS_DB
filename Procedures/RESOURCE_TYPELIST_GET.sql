use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[RESOURCE_TYPELIST_GET]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[RESOURCE_TYPELIST_GET]
go

set ansi_nulls on
go
set quoted_identifier on
go

CREATE PROCEDURE [dbo].[RESOURCE_TYPELIST_GET]
	@ShowArchived BIT = 0
AS
BEGIN
	SELECT
		wrt.WTS_RESOURCE_TYPEID
		, wrt.WTS_RESOURCE_TYPE
		, wrt.[DESCRIPTION]
		, wrt.SORT_ORDER
		, wrt.Archive
		, wrt.CreatedBy
		, wrt.CreatedDate
		, wrt.UpdatedBy
		, wrt.UpdatedDate
	FROM
		WTS_RESOURCE_TYPE wrt
	WHERE
		(ISNULL(@ShowArchived,1) = 1 OR wrt.Archive = @ShowArchived)
	ORDER BY wrt.SORT_ORDER ASC;
END;