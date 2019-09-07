USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_HasMeetingChangedSinceLastMeetingMinutes]    Script Date: 4/13/2018 4:04:24 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstance_HasMeetingChangedSinceLastMeetingMinutes]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_HasMeetingChangedSinceLastMeetingMinutes]    Script Date: 4/13/2018 4:04:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AORMeetingInstance_HasMeetingChangedSinceLastMeetingMinutes]
(
	@AORMeetingInstanceID INT,
	@MeetingChanged BIT = 0 OUTPUT
)
AS
BEGIN
	DECLARE @LastMeetingMinutesAttachmentID INT 
	DECLARE @LastMeetingMinutesAttachmentDate DATETIME
				
	SELECT TOP 1 
		@LastMeetingMinutesAttachmentID = att.AttachmentID,
		@LastMeetingMinutesAttachmentDate = att.CREATEDDATE
		FROM AORMeetingInstanceAttachment mia JOIN Attachment att ON (att.AttachmentId = mia.AttachmentID) 
		WHERE mia.AORMeetingInstanceID = @AORMeetingInstanceID AND att.AttachmentTypeId = 4 
		ORDER BY att.AttachmentID DESC

	DECLARE @LastMeetingInstanceUpdate DATETIME = (SELECT UpdatedDate FROM AORMeetingInstance WHERE AORMeetingInstanceID = @AORMeetingInstanceID)

	IF (@LastMeetingMinutesAttachmentID IS NULL OR @LastMeetingMinutesAttachmentDate IS NULL OR @LastMeetingInstanceUpdate > @LastMeetingMinutesAttachmentDate)
		SET @MeetingChanged = 1
	ELSE
		SET @MeetingChanged = 0		
END

GO


