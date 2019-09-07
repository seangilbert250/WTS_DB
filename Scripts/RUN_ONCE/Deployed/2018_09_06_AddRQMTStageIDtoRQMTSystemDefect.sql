USE WTS
GO

IF dbo.ColumnExists('dbo', 'RQMTSystemDefect', 'RQMTStageID') = 0
BEGIN
	ALTER TABLE RQMTSystemDefect ADD RQMTStageID INT NULL

	ALTER TABLE [dbo].[RQMTSystemDefect] WITH CHECK ADD CONSTRAINT [FK_RQMTSystemDefect_RQMTStageID] FOREIGN KEY([RQMTStageID])	REFERENCES [dbo].[RQMTAttribute] ([RQMTAttributeID])
END

GO

IF dbo.ColumnExists('dbo', 'RQMTSystemDefect', 'Mitigation') = 0
BEGIN
	ALTER TABLE RQMTSystemDefect ADD Mitigation NVARCHAR(MAX) NULL
END