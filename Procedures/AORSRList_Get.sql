use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORSRList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORSRList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORSRList_Get]
	@CRID int = 0
as
begin
	select SRID
	from AORSR
	where (@CRID = 0 or CRID = @CRID)
	order by SRID;
end;
