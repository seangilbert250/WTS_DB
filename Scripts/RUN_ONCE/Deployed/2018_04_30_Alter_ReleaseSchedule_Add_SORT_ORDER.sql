use [WTS]
go
IF dbo.ColumnExists('dbo','ReleaseSchedule','SORT_ORDER') = 0
BEGIN
ALTER TABLE ReleaseSchedule
    ADD SORT_ORDER int default 99 not null

END
go
