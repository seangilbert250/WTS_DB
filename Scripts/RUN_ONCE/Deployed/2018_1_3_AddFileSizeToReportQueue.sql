IF dbo.ColumnExists('dbo', 'ReportQueue', 'OutFileSize') = 0
BEGIN
	ALTER TABLE dbo.ReportQueue
	ADD
		OutFileSize BIGINT NULL
END