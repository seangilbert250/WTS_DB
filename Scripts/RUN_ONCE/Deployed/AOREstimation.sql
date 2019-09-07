use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[AOREstimation]') and type in (N'U'))
drop table [dbo].[AOREstimation]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[AOREstimation](
	[AOREstimationID] [int] identity(1,1) not null,
	[AOREstimationName] [nvarchar](150) not null,
	[Description] [nvarchar](500) null,
	[Notes] [nvarchar](max) null,
	[Sort] [int] null default (0),
	[Archive] [bit] not null default (0),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_AOREstimation] primary key clustered([AOREstimationID] ASC),
	constraint [UK_AOREstimation] unique([AOREstimationName])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
) on [PRIMARY]
go

insert into [dbo].[AOREstimation](
  [AOREstimationName]
, [Archive]
)
select 'Familiarity'
     , 0
union
select 'Process Volatility'
     , 0
union 
select 'Personnel Resources'
     , 0
union
select 'Non-Personnel Resources'
     , 0
union
select 'Effort'
     , 0
;
go