use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORCurrentRelease_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORCurrentRelease_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORCurrentRelease_Get]
as
begin
	select pv.ProductVersionID,
		pv.ProductVersion,
		cre.[Current]
	from AORCurrentRelease cre
	left join ProductVersion pv
	on cre.ProductVersionID = pv.ProductVersionID
	where cre.[Current] = 1;
end;
