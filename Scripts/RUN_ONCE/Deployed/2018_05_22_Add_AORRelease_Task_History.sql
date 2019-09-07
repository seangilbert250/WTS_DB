use [WTS]
go

set ansi_nulls on
go
set quoted_identifier on
go

if dbo.TableExists('dbo', 'AORReleaseTaskHistory') = 0
begin
	create table [dbo].[AORReleaseTaskHistory](
		[AORReleaseTaskHistoryID] [int] identity(1,1) not null,
		[AORReleaseID] [int] not null,
		[WORKITEMID] [int] not null,
		[Associate] [bit] null,
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_AORReleaseTaskHistory] primary key clustered([AORReleaseTaskHistoryID] ASC)
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_AORReleaseTaskHistory_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
			constraint [FK_AORReleaseTaskHistory_WORKITEM] foreign key ([WORKITEMID]) references [WORKITEM]([WORKITEMID])
	) on [PRIMARY]
end
go

if dbo.TableExists('dbo', 'AORReleaseSubTaskHistory') = 0
begin
	create table [dbo].[AORReleaseSubTaskHistory](
		[AORReleaseSubTaskHistoryID] [int] identity(1,1) not null,
		[AORReleaseID] [int] not null,
		[WORKITEM_TASKID] [int] not null,
		[Associate] [bit] null,
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_AORReleaseSubTaskHistory] primary key clustered([AORReleaseSubTaskHistoryID] ASC)
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_AORReleaseSubTaskHistory_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
			constraint [FK_AORReleaseSubTaskHistory_WORKITEM_TASK] foreign key ([WORKITEM_TASKID]) references [WORKITEM_TASK]([WORKITEM_TASKID])
	) on [PRIMARY]
end
go

if object_id ('AORReleaseTask_InsertTrigger','TR') is not null
   drop trigger AORReleaseTask_InsertTrigger;
go

create trigger AORReleaseTask_InsertTrigger on AORReleaseTask
for insert
as
begin
   insert into AORReleaseTaskHistory
   (AORReleaseID, WORKITEMID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)    
   select AORReleaseID, WORKITEMID, 1, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate
   from inserted;
end;
go

if object_id ('AORReleaseTask_DeleteTrigger','TR') is not null
   drop trigger AORReleaseTask_DeleteTrigger;
go

create trigger AORReleaseTask_DeleteTrigger on AORReleaseTask
for delete
as
begin
   insert into AORReleaseTaskHistory
   (AORReleaseID, WORKITEMID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)    
   select AORReleaseID, WORKITEMID, 0, '', getdate(), '', getdate()
   from deleted;
end;
go

if object_id ('AORReleaseSubTask_InsertTrigger','TR') is not null
   drop trigger AORReleaseSubTask_InsertTrigger;
go

create trigger AORReleaseSubTask_InsertTrigger on AORReleaseSubTask
for insert
as
begin
   insert into AORReleaseSubTaskHistory
   (AORReleaseID, WORKITEM_TASKID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)    
   select AORReleaseID, WORKITEMTASKID, 1, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate
   from inserted;
end;
go

if object_id ('AORReleaseSubTask_DeleteTrigger','TR') is not null
   drop trigger AORReleaseSubTask_DeleteTrigger;
go

create trigger AORReleaseSubTask_DeleteTrigger on AORReleaseSubTask
for delete
as
begin
   insert into AORReleaseSubTaskHistory
   (AORReleaseID, WORKITEM_TASKID, Associate, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)    
   select AORReleaseID, WORKITEMTASKID, 0, '', getdate(), '', getdate()
   from deleted;
end;
go
