use [WTS]
go

alter table WTS_SYSTEM_SUITE
add [ResourcesReviewedBy] [nvarchar](255) null
go

alter table WTS_SYSTEM_SUITE
add [ResourcesReviewedDate] [datetime] null
go