use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[RQMTDescriptionList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[RQMTDescriptionList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[RQMTDescriptionList_Get]
as
begin
	select rdt.RQMTDescriptionTypeID as RQMTDescriptionType_ID,
		rdt.RQMTDescriptionType as [RQMT Description Type],
		rde.RQMTDescriptionID as RQMTDescription_ID,
		rde.RQMTDescription as [RQMT Description],
		rde.Sort,
		'' as Z
	from RQMTDescription rde
	join RQMTDescriptionType rdt
	on rde.RQMTDescriptionTypeID = rdt.RQMTDescriptionTypeID
	where rde.Archive = 0
	order by rde.Sort;
end;
