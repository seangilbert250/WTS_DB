USE WTS
GO

IF dbo.ColumnExists('dbo', 'AORMeetingNotes', 'NoteGroupID') = 0
BEGIN
	ALTER TABLE dbo.AORMeetingNotes ADD NoteGroupID INT NULL
	
	GO

	CREATE INDEX IDX_AORMeetingNotes_Group
		ON dbo.AORMeetingNotes(NoteGroupID)
		
	GO
	
	UPDATE dbo.AORMeetingNotes SET NoteGroupID = AORMeetingNotesID
END