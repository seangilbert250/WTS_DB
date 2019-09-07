USE WTS
GO

IF dbo.TableExists('dbo', 'RQMTSet_Functionality') = 0
BEGIN

	CREATE TABLE dbo.RQMTSet_Functionality
	(
		RQMTSetFunctionalityID INT PRIMARY KEY IDENTITY(1,1),
		RQMTSetID INT NOT NULL,
		FunctionalityID INT NOT NULL,
		RQMTComplexityID INT NULL
	)

	CREATE UNIQUE INDEX IX_RQMTSet_Functionality
	ON dbo.RQMTSet_Functionality (RQMTSetID, FunctionalityID);

	ALTER TABLE dbo.RQMTSet_Functionality WITH CHECK ADD CONSTRAINT FK_RQMTSet_Functionality_RQMTSet FOREIGN KEY (RQMTSetID)
	REFERENCES dbo.RQMTSet (RQMTSetID)

	ALTER TABLE dbo.RQMTSet_Functionality WITH CHECK ADD CONSTRAINT FK_RQMTSet_Functionality_Functionality FOREIGN KEY (FunctionalityID)
	REFERENCES dbo.WorkloadGroup (WorkloadGroupID)

	ALTER TABLE dbo.RQMTSet_Functionality WITH CHECK ADD CONSTRAINT FK_RQMTSet_Functionality_Complexity FOREIGN KEY (RQMTComplexityID)
	REFERENCES dbo.RQMTComplexity (RQMTComplexityID)

	CREATE TABLE dbo.RQMTSet_RQMTSystem_Functionality
	(
		RQMTSet_RQMTSystemID INT NOT NULL,
		RQMTSetFunctionalityID INT NOT NULL
	)

	ALTER TABLE RQMTSet_RQMTSystem_Functionality
	ADD CONSTRAINT PK_RQMTSet_RQMTSystem_Functionality PRIMARY KEY (RQMTSet_RQMTSystemID, RQMTSetFunctionalityID)

	ALTER TABLE dbo.RQMTSet_RQMTSystem_Functionality WITH CHECK ADD CONSTRAINT FK_RQMTSet_RQMTSystem_Functionality_Set FOREIGN KEY (RQMTSet_RQMTSystemID)
	REFERENCES dbo.RQMTSet_RQMTSystem (RQMTSet_RQMTSystemID)

	ALTER TABLE dbo.RQMTSet_RQMTSystem_Functionality WITH CHECK ADD CONSTRAINT FK_RQMTSet_RQMTSystem_Functionality_Func FOREIGN KEY (RQMTSetFunctionalityID)
	REFERENCES dbo.RQMTSet_Functionality (RQMTSetFunctionalityID)

END


