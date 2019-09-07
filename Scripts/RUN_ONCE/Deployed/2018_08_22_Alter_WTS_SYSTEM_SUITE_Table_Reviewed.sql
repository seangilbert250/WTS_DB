use [WTS]
go

alter table WTS_SYSTEM_SUITE
add [SystemsReviewedBy] [nvarchar](255) null
go

alter table WTS_SYSTEM_SUITE
add [SystemsReviewedDate] [datetime] null
go