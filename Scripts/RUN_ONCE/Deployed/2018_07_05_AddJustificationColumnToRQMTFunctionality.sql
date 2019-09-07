USE WTS
GO

IF dbo.ColumnExists('dbo', 'RQMTSet_Functionality', 'Justification') = 0
BEGIN
	ALTER TABLE dbo.RQMTSet_Functionality ADD Justification NVARCHAR(1000) NULL
END