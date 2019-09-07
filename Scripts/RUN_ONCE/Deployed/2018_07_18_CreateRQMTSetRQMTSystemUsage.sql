USE WTS
GO

IF dbo.TableExists('dbo', 'RQMTSet_RQMTSystem_Usage') = 0
BEGIN
	CREATE TABLE dbo.RQMTSet_RQMTSystem_Usage
	(
		RQMTSet_RQMTSystem_UsageID INT PRIMARY KEY IDENTITY(1,1),
		RQMTSet_RQMTSystemID INT NOT NULL,
		Month_1 BIT,
		Month_2 BIT,
		Month_3 BIT,
		Month_4 BIT,
		Month_5 BIT,
		Month_6 BIT,
		Month_7 BIT,
		Month_8 BIT,
		Month_9 BIT,
		Month_10 BIT,
		Month_11 BIT,
		Month_12 BIT
	)

	CREATE UNIQUE INDEX IX_RQMTSet_RQMTSystem_Usage
	ON dbo.RQMTSet_RQMTSystem_Usage (RQMTSet_RQMTSystemID)

	ALTER TABLE dbo.RQMTSet_RQMTSystem_Usage WITH CHECK ADD CONSTRAINT FK_RQMTSet_RQMTSystem_Usage FOREIGN KEY (RQMTSet_RQMTSystemID)
	REFERENCES dbo.RQMTSet_RQMTSystem (RQMTSet_RQMTSystemID)
END