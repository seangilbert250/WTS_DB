CREATE TABLE dbo.AORMeetingInstanceAttachment
(
	AORMeetingInstanceAttachmentID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	AORMeetingInstanceID INT NOT NULL,
	AttachmentID INT NOT NULL
)

CREATE INDEX IDX_AORMeetingInstanceAttachment_Meeting
	ON dbo.AORMeetingInstanceAttachment(AORMeetingInstanceID, AORMeetingInstanceAttachmentID)
	
CREATE INDEX IDX_AORMeetingInstanceAttachment_Attachment
	ON dbo.AORMeetingInstanceAttachment(AttachmentID)
	
ALTER TABLE dbo.AORMeetingInstanceAttachment  WITH CHECK ADD CONSTRAINT [FK_AORMeetingInstanceAttachment_Meeting] FOREIGN KEY([AORMeetingInstanceID])
REFERENCES [dbo].AORMeetingInstance (AORMeetingInstanceID)

ALTER TABLE dbo.AORMeetingInstanceAttachment  WITH CHECK ADD CONSTRAINT [FK_AORMeetingInstanceAttachment_Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].Attachment (AttachmentID)

GO