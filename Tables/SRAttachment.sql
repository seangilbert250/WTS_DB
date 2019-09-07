use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[SRAttachment]') and type in (N'U'))
drop table [dbo].SRAttachment
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].SRAttachment(
	[SRAttachmentID] [int] identity(1,1) not null,
	[SRID] [int] not null,
	[FileName] [nvarchar](150) not null,
	[FileData] [varbinary](max) null,
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_SRAttachment] primary key clustered([SRAttachmentID] ASC),
	constraint [UK_SRAttachment] unique([SRID], [FileName])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
		constraint [FK_SRAttachment_SR] foreign key ([SRID]) references [SR]([SRID])
) on [PRIMARY]
go
