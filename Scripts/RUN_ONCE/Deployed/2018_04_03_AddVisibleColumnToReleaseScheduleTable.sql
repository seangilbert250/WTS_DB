use [WTS]
go

ALTER TABLE ReleaseSchedule
    ADD Visible bit
go

UPDATE ReleaseSchedule
    SET Visible = 1
go