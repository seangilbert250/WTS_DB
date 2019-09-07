USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAttachment_Get]    Script Date: 3/22/2018 10:13:16 AM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAttachment_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAttachment_Get]    Script Date: 3/22/2018 10:13:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORMeetingInstanceAttachment_Get]
(
	@AORMeetingInstanceAttachmentID BIGINT = 0,
	@AORMeetingID INT = 0,
	@AORMeetingInstanceID INT = 0,
	@AttachmentID INT = 0,
	@IncludeData BIT = 0
)

AS

-- NOTE, I ORIGINALLY TRIED 'CASE WHEN @IncludeData = 1 THEN att.FileData ELSE NULL END AS FileData', BUT FOR SOME REASON, THE DATA TABLE CAN'T HANDLE NULL VARBINARY. I TRIED
-- A FEW VARIATIONS WITHOUT BREAKING THE COLUMN LIST, AND NOTHING WORKED; SO FOR NOW, WE ARE USING TWO SEPARATE SELECTS

IF @IncludeData = 1
	SELECT
		mia.AORMeetingInstanceAttachmentID,
		mia.AORMeetingInstanceID,
		mia.AttachmentID,
		att.AttachmentTypeId,
		att.FileName,
		att.Title,
		att.Description,
		att.FileData,
		att.ExtensionID,
		att.Archive,
		att.CREATEDBY,
		att.CREATEDDATE,
		att.UPDATEDBY,
		att.UPDATEDDATE,
		att.BUGTRACKER_ID,
		at.ATTACHMENTTYPE,
		ami.InstanceDate

	FROM AORMeetingInstanceAttachment mia
		JOIN Attachment att ON (att.AttachmentId = mia.AttachmentID)
		JOIN AttachmentType at ON (at.AttachmentTypeId = att.AttachmentTypeId)
		LEFT JOIN AORMeetingInstance ami ON (ami.AORMeetingInstanceID = mia.AORMeetingInstanceID)
	WHERE 
		(@AORMeetingInstanceAttachmentID > 0 AND mia.AORMeetingInstanceAttachmentID = @AORMeetingInstanceAttachmentID)
		OR (@AORMeetingInstanceID > 0 AND mia.AORMeetingInstanceID = @AORMeetingInstanceID)
		OR (@AORMeetingID > 0 AND ami.AORMeetingID = @AORMeetingID)
		OR (@AttachmentID > 0 AND mia.AttachmentID = @AttachmentID)
	ORDER BY
		CASE WHEN @AORMeetingID > 0 THEN ami.InstanceDate ELSE 0 END DESC,
		att.FileName, mia.AORMeetingInstanceAttachmentID
ELSE
	SELECT
		mia.AORMeetingInstanceAttachmentID,
		mia.AORMeetingInstanceID,
		mia.AttachmentID,
		att.AttachmentTypeId,
		att.FileName,
		att.Title,
		att.Description,
		0 AS FileData,
		att.ExtensionID,
		att.Archive,
		att.CREATEDBY,
		att.CREATEDDATE,
		att.UPDATEDBY,
		att.UPDATEDDATE,
		att.BUGTRACKER_ID,
		at.ATTACHMENTTYPE,
		ami.InstanceDate

	FROM AORMeetingInstanceAttachment mia
		JOIN Attachment att ON (att.AttachmentId = mia.AttachmentID)
		JOIN AttachmentType at ON (at.AttachmentTypeId = att.AttachmentTypeId)
		LEFT JOIN AORMeetingInstance ami ON (ami.AORMeetingInstanceID = mia.AORMeetingInstanceID)
	WHERE 
		(@AORMeetingInstanceAttachmentID > 0 AND mia.AORMeetingInstanceAttachmentID = @AORMeetingInstanceAttachmentID)
		OR (@AORMeetingInstanceID > 0 AND mia.AORMeetingInstanceID = @AORMeetingInstanceID)
		OR (@AORMeetingID > 0 AND ami.AORMeetingID = @AORMeetingID)
		OR (@AttachmentID > 0 AND mia.AttachmentID = @AttachmentID)
	ORDER BY
		CASE WHEN @AORMeetingID > 0 THEN ami.InstanceDate ELSE 0 END DESC,
		att.FileName, mia.AORMeetingInstanceAttachmentID
GO


