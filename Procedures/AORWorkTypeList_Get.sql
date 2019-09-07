use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORWorkTypeList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORWorkTypeList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORWorkTypeList_Get]
as
begin
	select AORWorkTypeID as AORWorkType_ID,
		AORWorkTypeName as [Work Type]
	from AORWorkType
	order by upper(AORWorkTypeName);
end;
