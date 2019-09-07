use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORFrequency]') and type in (N'U'))
drop table [dbo].[AORFrequency]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORFrequency](
	[AORFrequencyID] [int] identity(1,1) not null,
	[AORFrequencyName] [nvarchar](150) not null,
	[Description] [nvarchar](500) null,
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORFrequency] primary key clustered([AORFrequencyID] ASC),
	constraint [UK_AORFrequency] unique([AORFrequencyName])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
) on [PRIMARY]
go
