use [WTS]
go

if [dbo].TableExists('dbo', 'RQMT') = 0
begin
	create table [dbo].[RQMT](
		[RQMTID] [int] identity(1,1) not null,
		[RQMT] [nvarchar](500) not null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMT] primary key clustered([RQMTID] ASC),
		constraint [UK_RQMT] unique([RQMT])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
	) on [PRIMARY]
end;
go
