use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[SprintBuilderHistory_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[SprintBuilderHistory_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[SprintBuilderHistory_Get]
	@WORKITEMID int,
	@WORKITEM_TASKID int
as
begin
	if @WORKITEM_TASKID = -1
		select FieldChanged
		     , isnull(OldValue,'') as OldValue
			 , isnull(NewValue,'') as NewValue
			 , CREATEDBY
			 , CREATEDDATE
			 , UPDATEDBY
			 , UPDATEDDATE
		from WorkItem_History
		where WORKITEMID = @WORKITEMID
		and FieldChanged = 'Workload MGMT AOR'
		order by CREATEDDATE, UPDATEDDATE
		;
	else
		select FieldChanged
		     , isnull(OldValue,'') as OldValue
			 , isnull(NewValue,'') as NewValue
			 , CREATEDBY
			 , CREATEDDATE
			 , UPDATEDBY
			 , UPDATEDDATE		
		from WORKITEM_TASK_HISTORY
		where WORKITEM_TASKID = @WORKITEM_TASKID
		and FieldChanged = 'Workload MGMT AOR'
		order by CREATEDDATE, UPDATEDDATE
		;
end;

