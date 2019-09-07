USE [WTS]
GO

--------------------------------------------------------

CREATE function [dbo].[ProcedureExists]
(
	@SchemaName VARCHAR(100),
	@ProcedureName VARCHAR(100)
)
RETURNS INT

AS

BEGIN
	DECLARE @exists BIT = 0

	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = @SchemaName AND ROUTINE_NAME = @ProcedureName AND ROUTINE_TYPE = 'PROCEDURE'))
		SET @exists = 1
	ELSE
		SET @exists = 0

	RETURN @exists
END
GO

--------------------------------------------------------

IF dbo.TableExists('dbo', 'RQMTSetName') = 0
BEGIN
	CREATE TABLE [dbo].[RQMTSetName](
		[RQMTSetNameID] [int] IDENTITY(1,1) NOT NULL,
		[RQMTSetName] [nvarchar](100) NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		[RQMTSetNameID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	/****** Object:  Index [IDX_RQMTSetName]    Script Date: 4/30/2018 10:02:08 AM ******/
	CREATE UNIQUE NONCLUSTERED INDEX [IDX_RQMTSetName] ON [dbo].[RQMTSetName]
	(
		[RQMTSetName] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END

GO

----------------------------------------------------------------------------------------------------

IF dbo.TableExists('dbo', 'RQMTSetType') = 0
BEGIN
	CREATE TABLE [dbo].[RQMTSetType](
		[RQMTSetTypeID] [int] IDENTITY(1,1) NOT NULL,
		[RQMTSetNameID] [int] NOT NULL,
		[RQMTTypeID] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
	(
		[RQMTSetTypeID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[RQMTSetType]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSetType_RQMTSetName] FOREIGN KEY([RQMTSetNameID])
	REFERENCES [dbo].[RQMTSetName] ([RQMTSetNameID])

	ALTER TABLE [dbo].[RQMTSetType] CHECK CONSTRAINT [FK_RQMTSetType_RQMTSetName]

	ALTER TABLE [dbo].[RQMTSetType]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSetType_RQMTType] FOREIGN KEY([RQMTTypeID])
	REFERENCES [dbo].[RQMTType] ([RQMTTypeID])

	ALTER TABLE [dbo].[RQMTSetType] CHECK CONSTRAINT [FK_RQMTSetType_RQMTType]

	ALTER TABLE dbo.RQMTSetType ADD CONSTRAINT UC_RQMTSetType UNIQUE (RQMTSetNameID, RQMTTypeID)
END

GO

----------------------------------------------------------------------------------------------------

IF dbo.TableExists('dbo', 'RQMTSet') = 0
BEGIN
	CREATE TABLE dbo.RQMTSet
	(
		RQMTSetID INT PRIMARY KEY IDENTITY,
		WorkArea_SystemId INT NOT NULL,
		RQMTSetTypeID INT NOT NULL,
		Archive BIT NOT NULL,
		CreatedBy NVARCHAR(255) NOT NULL,
		CreatedDate DATETIME NOT NULL,
		UpdatedBy NVARCHAR(255) NOT NULL,
		UpdatedDate DATETIME NOT NULL
	)

	ALTER TABLE dbo.RQMTSet WITH CHECK ADD CONSTRAINT FK_RQMTSet_WorkArea_System FOREIGN KEY(WorkArea_SystemId)
	REFERENCES dbo.WorkArea_System (WorkArea_SystemId)

	ALTER TABLE dbo.RQMTSet WITH CHECK ADD CONSTRAINT FK_RQMTSet_RQMTSetType FOREIGN KEY(RQMTSetTypeID)
	REFERENCES dbo.RQMTSetType (RQMTSetTypeID)
END

GO

----------------------------------------------------------------------------------------------------

IF dbo.TableExists('dbo', 'RQMTSet_RQMTSystem') = 0
BEGIN
	CREATE TABLE dbo.RQMTSet_RQMTSystem
	(
		RQMTSet_RQMTSystemID INT PRIMARY KEY IDENTITY,
		RQMTSetID INT NOT NULL,
		RQMTSystemID INT NOT NULL,
		ParentRQMTSet_RQMTSystemID INT NULL,
		OutlineIndex INT NOT NULL,
		PRIORITYID INT
	)

	ALTER TABLE dbo.RQMTSet_RQMTSystem WITH CHECK ADD CONSTRAINT FK_RQMTSet_RQMTSystem_RQMTSet FOREIGN KEY (RQMTSetID)
	REFERENCES dbo.RQMTSet (RQMTSetID)

	ALTER TABLE dbo.RQMTSet_RQMTSystem WITH CHECK ADD CONSTRAINT FK_RQMTSet_RQMTSystem_RQMTSystem FOREIGN KEY (RQMTSystemID)
	REFERENCES dbo.RQMTSystem (RQMTSystemID)

	ALTER TABLE dbo.RQMTSet_RQMTSystem WITH CHECK ADD CONSTRAINT FK_RQMTSet_RQMTSystem_Parent FOREIGN KEY (RQMTSet_RQMTSystemID)
	REFERENCES dbo.RQMTSet_RQMTSystem (RQMTSet_RQMTSystemID)

	ALTER TABLE dbo.RQMTSet_RQMTSystem WITH CHECK ADD CONSTRAINT FK_RQMTSet_RQMTSystem_PRIORITYID FOREIGN KEY (PRIORITYID)
	REFERENCES dbo.PRIORITY (PRIORITYID)
	
	CREATE NONCLUSTERED INDEX [IDX_RQMTSet_RQMTSystem_RQMTSet] ON [dbo].RQMTSet_RQMTSystem
	(
		RQMTSetID ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	CREATE NONCLUSTERED INDEX [IDX_RQMTSet_RQMTSystem_RQMTSystem] ON [dbo].RQMTSet_RQMTSystem
	(
		RQMTSystemID ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	CREATE UNIQUE NONCLUSTERED INDEX [IDX_RQMTSet_RQMTSystem] ON [dbo].RQMTSet_RQMTSystem
	(
		RQMTSetID ASC,
		RQMTSystemID ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END



----------------------------------------------------------------------------------------------------

IF dbo.TableExists('dbo', 'WorkAreaSystem_RQMTSystemRQMTType') = 1
BEGIN
	DROP TABLE dbo.WorkAreaSystem_RQMTSystemRQMTType
END

IF dbo.ProcedureExists('dbo', 'RQMTSystemList_Get') = 1
BEGIN
	DROP PROCEDURE dbo.RQMTSystemList_Get
END

IF dbo.ColumnExists('dbo', 'RQMTSystem', 'PRIORITYID') = 1
BEGIN
	ALTER TABLE dbo.RQMTSystem DROP COLUMN PRIORITYID
END

GO

----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------