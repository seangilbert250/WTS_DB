USE WTS
GO

IF dbo.ColumnExists('dbo', 'ReportQueue', 'ExecutionStartDate') = 0
BEGIN

ALTER TABLE dbo.ReportQueue
ADD
	ExecutionStartDate DATETIME NULL
END