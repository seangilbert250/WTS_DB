use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORRoleGroup]') and type in (N'U'))
drop table [dbo].AORRoleGroup
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].AORRoleGroup(
	[AORRoleGroupID] [int] identity(1,1) not null,
	[AORRoleID] [int] not null,
	[AORGroupID] [int] not null,
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORRoleGroup] primary key clustered([AORRoleGroupID] ASC),
	constraint [UK_AORRoleGroup] unique([AORRoleID], [AORGroupID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_AORRoleTeam_AORRole] foreign key ([AORRoleID]) references [AORRole]([AORRoleID]),
		constraint [FK_AORRoleTeam_AORGroup] foreign key ([AORGroupID]) references [AORGroup]([AORGroupID])
) on [PRIMARY]
go
