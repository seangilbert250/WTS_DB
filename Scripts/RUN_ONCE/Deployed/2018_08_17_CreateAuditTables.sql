USE WTS
GO

--DROP TABLE dbo.AuditLogType
--DROP TABLE dbo.AuditLogUpdateType

CREATE TABLE dbo.AuditLogType
(
	AuditLogTypeID INT PRIMARY KEY,
	AuditLogType NVARCHAR(100)
)
GO


CREATE TABLE dbo.AuditLog
(
	AuditLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
	ItemID INT NOT NULL,
	ParentItemID INT NULL,
	AuditLogTypeID INT NOT NULL,
	ITEM_UPDATETYPEID INT NOT NULL,
	FieldChanged NVARCHAR(100) NOT NULL,
	OldValue NVARCHAR(MAX) NULL,
	NewValue NVARCHAR(MAX) NULL,
	UpdatedDate DATETIME NOT NULL,
	UpdatedBy NVARCHAR(255) NOT NULL
)
GO

CREATE INDEX IX_AuditLog_Type ON dbo.AuditLog (AuditLogTypeID)
CREATE INDEX IX_AuditLog_Item ON dbo.AuditLog (AuditLogTypeID, ItemID)
CREATE INDEX IX_AuditLog_ParentItem ON dbo.AuditLog (AuditLogTypeID, ParentItemID)
GO

ALTER TABLE dbo.AuditLog ADD CONSTRAINT FK_AuditLog_Type FOREIGN KEY (AuditLogTypeID) REFERENCES dbo.AuditLogType (AuditLogTypeID)
ALTER TABLE dbo.AuditLog ADD CONSTRAINT FK_AuditLog_UpdateType FOREIGN KEY (ITEM_UPDATETYPEID) REFERENCES dbo.ITEM_UPDATETYPE (ITEM_UPDATETYPEID)
GO

INSERT INTO dbo.AuditLogType VALUES (1, 'RQMT')
INSERT INTO dbo.AuditLogType VALUES (2, 'RQMTSET')
INSERT INTO dbo.AuditLogType VALUES (3, 'RQMTDEFECT')
INSERT INTO dbo.AuditLogType VALUES (4, 'RQMTFUNCTIONALITY')
INSERT INTO dbo.AuditLogType VALUES (5, 'RQMTSETFUNCTIONALITY')
INSERT INTO dbo.AuditLogType VALUES (6, 'RQMTSETUSAGE')
INSERT INTO dbo.AuditLogType VALUES (7, 'RQMTSYSTEM')

GO