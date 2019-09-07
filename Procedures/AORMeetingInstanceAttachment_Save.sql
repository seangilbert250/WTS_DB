USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAttachment_Save]    Script Date: 9/4/2018 4:46:48 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAttachment_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAttachment_Save]    Script Date: 9/4/2018 4:46:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORMeetingInstanceAttachment_Save]
(
	@AORMeetingInstanceAttachmentID BIGINT,
	@AORMeetingInstanceID INT,
	@AttachmentID INT
)

AS

IF @AORMeetingInstanceAttachmentID = 0
	INSERT INTO AORMeetingInstanceAttachment VALUES (@AORMeetingInstanceID, @AttachmentID)
ELSE
	UPDATE AORMeetingInstanceAttachment
	SET
		AORMeetingInstanceID = @AORMeetingInstanceID,
		AttachmentID = @AttachmentID
	WHERE
		AORMeetingInstanceAttachmentID = @AORMeetingInstanceAttachmentID














SELECT 'Executing File [Procedures\AORMassChange_Save.sql]';
GO


