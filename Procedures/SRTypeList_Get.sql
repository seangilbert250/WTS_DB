use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[SRTypeList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[SRTypeList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[SRTypeList_Get]
	@IncludeArchive int = 0
as
begin
	select * from (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		select
			'' as A,
			0 as SRTypeID,
			'' as SRType,
			'' as [Description],
			0 as Sort,
			0 as Archive,
			'' as X,
			'' as CreatedBy,
			'' as CreatedDate,
			'' as UpdatedBy,
			'' as UpdatedDate
		union all
		select
			'' as A,
			SRTypeID,
			SRType,
			[Description],
			Sort,
			Archive,
			'' as X,
			CreatedBy,
			CreatedDate,
			UpdatedBy,
			UpdatedDate
		from SRType
		where (isnull(@IncludeArchive, 1) = 1 or Archive = @IncludeArchive)
	) a
	order by a.Sort, a.SRType
end;
