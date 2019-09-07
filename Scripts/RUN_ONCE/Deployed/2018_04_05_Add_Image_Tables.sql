use [WTS]
go

if [dbo].TableExists('dbo', 'Image') = 0
begin
	create table [dbo].[Image](
		[ImageID] [int] identity(1,1) not null,
		[ImageName] [nvarchar](500) null,
		[Description] [nvarchar](500) null,
		[FileName] [nvarchar](500) not null,
		[FileData] [varbinary](max) null,
		[ContentType] [nvarchar](100) null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_Image] primary key clustered([ImageID] ASC)
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
	) on [PRIMARY]
end;
go

if [dbo].TableExists('dbo', 'Image_CONTRACT') = 0
begin
	create table [dbo].[Image_CONTRACT](
		[Image_CONTRACTID] [int] identity(1,1) not null,
		[ImageID] [int] not null,
		[ProductVersionID] [int] not null,
		[CONTRACTID] [int] not null,
		[ReleaseProductionStatusID] [int] null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_Image_CONTRACT] primary key clustered([Image_CONTRACTID] ASC),
		constraint [UK_Image_CONTRACT] unique([ImageID], [ProductVersionID], [CONTRACTID])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_Image_CONTRACT_Image] foreign key ([ImageID]) references [Image]([ImageID]),
			constraint [FK_Image_CONTRACT_ProductVersion] foreign key ([ProductVersionID]) references [ProductVersion]([ProductVersionID]),
			constraint [FK_Image_CONTRACT_CONTRACT] foreign key ([CONTRACTID]) references [CONTRACT]([CONTRACTID]),
			constraint [FK_Image_CONTRACT_ReleaseProductionStatus] foreign key ([ReleaseProductionStatusID]) references [STATUS]([STATUSID])
	) on [PRIMARY]
end;
go