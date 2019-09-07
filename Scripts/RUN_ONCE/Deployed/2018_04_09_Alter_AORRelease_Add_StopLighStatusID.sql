use [WTS]
go
IF dbo.ColumnExists('dbo','AORRelease','StopLightStatusID') = 0
BEGIN
ALTER TABLE AORRelease
    ADD StopLightStatusID int null


ALTER TABLE AORRelease
    ADD constraint [FK_AORRelease_StopLightStatus] foreign key ([StopLightStatusID]) references [STATUS]([STATUSID])

END
go