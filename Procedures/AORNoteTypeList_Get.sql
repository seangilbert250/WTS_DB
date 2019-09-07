use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORNoteTypeList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORNoteTypeList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORNoteTypeList_Get]
as
begin
	select AORNoteTypeID as AORNoteType_ID,
		AORNoteTypeName as [Note Type]
	from AORNoteType
	order by upper(AORNoteTypeName);
end;
