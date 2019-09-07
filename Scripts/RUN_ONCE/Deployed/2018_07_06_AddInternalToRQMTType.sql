USE WTS
GO

IF dbo.ColumnExists('dbo', 'RQMTType', 'Internal') = 0
BEGIN
	ALTER TABLE dbo.RQMTType ADD Internal BIT DEFAULT 0 NOT NULL
END