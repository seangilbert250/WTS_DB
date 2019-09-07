use [WTS]
go

alter table WTS_SYSTEM
add [WorkAreasReviewedBy] [nvarchar](255) null
go

alter table WTS_SYSTEM
add [WorkAreasReviewedDate] [datetime] null
go