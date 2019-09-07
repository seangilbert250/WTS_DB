use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WTS_SYSTEM_CONTRACT]') and type in (N'U'))
drop table [dbo].[WTS_SYSTEM_CONTRACT]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WTS_SYSTEM_CONTRACT](
	[WTS_SYSTEM_CONTRACTID] [int] identity(1,1) not null,
	[WTS_SYSTEMID] [int] not null,
	[CONTRACTID] [int] not null,
	[Primary] [bit] not null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_WTS_SYSTEM_CONTRACT] primary key clustered([WTS_SYSTEM_CONTRACTID] ASC),
	constraint [UK_WTS_SYSTEM_CONTRACT] unique([WTS_SYSTEMID], [CONTRACTID])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_WTS_SYSTEM_CONTRACT_WTS_SYSTEM] foreign key ([WTS_SYSTEMID]) references [WTS_SYSTEM]([WTS_SYSTEMID]),
		constraint [FK_WTS_SYSTEM_CONTRACT_CONTRACT] foreign key ([CONTRACTID]) references [CONTRACT]([CONTRACTID])
) on [PRIMARY]
go
