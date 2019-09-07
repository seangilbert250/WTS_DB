use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AORSRImport]') and type in (N'U'))
drop table [dbo].[AORSRImport]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AORSRImport](
	[AORSRImportID] [int] identity(1,1) not null,
	[FileName] [nvarchar](150) not null,
	[ImportBy] [nvarchar](255) not null default ('WTS'),
	[ImportDate] [datetime] not null default (getdate()),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AORSRImport] primary key clustered([AORSRImportID] ASC)
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
) on [PRIMARY]
go
