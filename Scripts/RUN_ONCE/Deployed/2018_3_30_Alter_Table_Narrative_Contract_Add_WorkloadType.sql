use WTS
GO
IF dbo.ColumnExists('dbo','Narrative_CONTRACT','ReleaseProductionStatusID') = 0
BEGIN

	ALTER TABLE [WTS].[dbo].[Narrative_CONTRACT] ADD ReleaseProductionStatusID [int] not null
	
	ALTER TABLE [dbo].[Narrative_CONTRACT]  WITH CHECK ADD  CONSTRAINT [FK_ReleaseProductionStatus] FOREIGN KEY([ReleaseProductionStatusID])
	REFERENCES [dbo].[STATUS] ([STATUSID])
	
	ALTER TABLE [dbo].[Narrative_CONTRACT] CHECK CONSTRAINT [FK_ReleaseProductionStatus]

END
GO
