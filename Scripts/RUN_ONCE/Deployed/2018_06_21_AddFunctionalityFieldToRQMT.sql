USE WTS
GO

IF dbo.ColumnExists('dbo', 'RQMTSet', 'WorloadGroupID') = 0
BEGIN
	ALTER TABLE RQMTSet ADD WorkloadGroupID INT NOT NULL DEFAULT 1

	ALTER TABLE [dbo].[RQMTSet]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSet_WorkloadGroup] FOREIGN KEY(WorkloadGroupID)
	REFERENCES [dbo].WorkloadGroup (WorkloadGroupID)
END
