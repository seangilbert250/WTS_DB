use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORRoleList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORRoleList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORRoleList_Get]
as
begin
	select AORRoleID as AORRole_ID,
		AORRoleName as [Role]
	from AORRole
	order by upper(AORRoleName);
end;
