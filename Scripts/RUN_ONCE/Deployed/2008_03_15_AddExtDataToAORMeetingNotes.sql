IF dbo.ColumnExists('dbo','AORMeetingNotes','ExtData') = 0
BEGIN
	ALTER TABLE dbo.AORMeetingNotes ADD ExtData NVARCHAR(MAX) NULL
END