use [WTS]
go

if exists (select * from sys.objects where object_id = object_id(N'[dbo].[WTS_RESOURCE_TYPE]') and type in (N'U'))
drop table [dbo].[WTS_RESOURCE_TYPE]
go

set ansi_nulls on
go
set quoted_identifier on
go

create table [dbo].[WTS_RESOURCE_TYPE](
	[WTS_RESOURCE_TYPEID] [int] identity(1,1) not null,
	[WTS_RESOURCE_TYPE]  [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](255) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CreatedBy] [nvarchar](255) not null default ('WTS'),
	[CreatedDate] [datetime] not null default (getdate()),
	[UpdatedBy] [nvarchar](255) not null default ('WTS'),
	[UpdatedDate] [datetime] not null default (getdate()),
	constraint [PK_WTS_RESOURCE_TYPE] primary key clustered([WTS_RESOURCE_TYPEID] ASC),
	constraint [UK_WTS_RESOURCE_TYPE] unique([WTS_RESOURCE_TYPE])
	with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY]
) on [PRIMARY]
go

--INSERT WTS RESOURCE TYPE
INSERT INTO [WTS_RESOURCE_TYPE]([WTS_RESOURCE_TYPE],[DESCRIPTION],[SORT_ORDER])
VALUES ('Business Analyst', 'Business Analyst', 1);

INSERT INTO [WTS_RESOURCE_TYPE]([WTS_RESOURCE_TYPE],[DESCRIPTION],[SORT_ORDER])
VALUES ('Programmer Analyst', 'Programmer Analyst', 2);

INSERT INTO [WTS_RESOURCE_TYPE]([WTS_RESOURCE_TYPE],[DESCRIPTION],[SORT_ORDER])
VALUES ('Cyber Team', 'Cyber Team', 3);

ALTER TABLE WTS_RESOURCE
ADD WTS_RESOURCE_TYPEID int;

ALTER TABLE WTS_RESOURCE
ADD CONSTRAINT [FK_WTS_RESOURCE_WTS_RESOURCE_TYPE] FOREIGN KEY (WTS_RESOURCE_TYPEID) REFERENCES [WTS_RESOURCE_TYPE]([WTS_RESOURCE_TYPEID]);

update WTS_RESOURCE
set WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
from WTS_RESOURCE_TYPE wrt
where WTS_RESOURCE.IsDeveloper = 1
and wrt.WTS_RESOURCE_TYPE = 'Programmer Analyst' ;

update WTS_RESOURCE
set WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
from WTS_RESOURCE_TYPE wrt
where WTS_RESOURCE.IsBusAnalyst = 1
and wrt.WTS_RESOURCE_TYPE = 'Business Analyst' ;