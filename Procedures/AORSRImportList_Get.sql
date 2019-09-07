use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORSRImportList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORSRImportList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORSRImportList_Get]
as
begin
	select [FileName],
		ImportBy,
		ImportDate
	from AORSRImport
	order by ImportDate desc;
end;
