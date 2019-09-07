USE WTS
GO

IF (dbo.ColumnExists('dbo', 'AttachmentType', 'ShowInLists') = 0)
BEGIN
	ALTER TABLE dbo.AttachmentType ADD ShowInLists BIT NOT NULL DEFAULT (1)
END

GO

IF NOT EXISTS (SELECT 1 FROM AttachmentType WHERE AttachmentType = 'MEETING MINUTES')
BEGIN
	DECLARE @now DATETIME = GETDATE()

	INSERT INTO AttachmentType VALUES ('MEETING MINUTES', 'MEETING MINUTES', 4, 0, 'WTS_ADMIN', @now, 'WTS_ADMIN', @now, 0)
END

GO

UPDATE Attachment SET AttachmentTypeId = 4 
WHERE Title  LIKE '%Minutes'
AND Description IS NULL

GO


