IF dbo.ColumnExists('dbo', 'AORMeetingInstance', 'MeetingAccepted') = 0
BEGIN
	ALTER TABLE dbo.AORMeetingInstance ADD
		MeetingAccepted BIT NOT NULL DEFAULT 0
END