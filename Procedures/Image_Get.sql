use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[Image_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[Image_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[Image_Get]
	@ImageID int
as
begin
	select [FileName],
		FileData
	from [Image]
	where ImageID = @ImageID;
end;
