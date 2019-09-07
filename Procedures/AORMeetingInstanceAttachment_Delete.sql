USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAttachment_Delete]    Script Date: 1/29/2018 2:29:59 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAttachment_Delete]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAttachment_Delete]    Script Date: 1/29/2018 2:29:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AORMeetingInstanceAttachment_Delete]
(
	@AORMeetingInstanceAttachmentID BIGINT = 0,
	@AORMeetingInstanceID INT = 0,
	@AttachmentID INT = 0
)

AS

DELETE FROM AORMeetingInstanceAttachment 
WHERE 
	(@AORMeetingInstanceAttachmentID > 0 AND AORMeetingInstanceAttachmentID = @AORMeetingInstanceAttachmentID)
	OR (@AORMeetingInstanceID > 0 AND AORMeetingInstanceID = @AORMeetingInstanceID)
	OR (@AttachmentID > 0 AND AttachmentID = @AttachmentID)





SELECT 'Executing File [Procedures\AORMeetingInstanceSelectedNoteDetail_Get.sql]';
GO


