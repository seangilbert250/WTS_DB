use [WTS]
go

if [dbo].TableExists('dbo', 'RQMTComplexity') = 0
begin
	create table [dbo].[RQMTComplexity](
		[RQMTComplexityID] [int] identity(1,1) not null,
		[RQMTComplexity] [nvarchar](150) not null,
		[Description] [nvarchar](500) null,
		[Points] [int] null,
		[Sort] [int] null default (0),
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_RQMTComplexity] primary key clustered([RQMTComplexityID] ASC),
		constraint [UK_RQMTComplexity] unique([RQMTComplexity])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
	) on [PRIMARY];

	declare @date datetime = getdate();

	insert into RQMTComplexity(RQMTComplexity, [Description], Points, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
	select 'XXS', 'XXS', 1, 1, 0, 'WTS', @date, 'WTS', @date
	union all
	select 'XS', 'XS', 2, 2, 0, 'WTS', @date, 'WTS', @date
	union all
	select 'S', 'S', 3, 3, 0, 'WTS', @date, 'WTS', @date
	union all
	select 'M', 'M', 5, 4, 0, 'WTS', @date, 'WTS', @date
	union all
	select 'L', 'L', 8, 5, 0, 'WTS', @date, 'WTS', @date
	union all
	select 'XL', 'XL', 13, 6, 0, 'WTS', @date, 'WTS', @date
	union all
	select 'XXL', 'XXL', 21, 7, 0, 'WTS', @date, 'WTS', @date
	union all
	select 'TBD', 'TBD', null, 8, 0, 'WTS', @date, 'WTS', @date;
end;
go
