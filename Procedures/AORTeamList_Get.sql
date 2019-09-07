use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORTeamList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORTeamList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORTeamList_Get]
as
begin
	select AORTeamID as AORTeam_ID,
		AORTeamName as Team
	from AORTeam
	order by upper(AORTeamName);
end;
