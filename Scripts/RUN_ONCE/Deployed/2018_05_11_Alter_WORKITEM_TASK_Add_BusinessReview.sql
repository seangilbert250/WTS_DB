use [WTS]
go

alter table WORKITEM
add BusinessReview bit not null default(0);
go

alter table WORKITEM_TASK
add BusinessReview bit not null default(0);
go
