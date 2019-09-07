USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDescriptionAttachment_Get]    Script Date: 9/5/2018 9:47:51 AM ******/
DROP PROCEDURE [dbo].[RQMTDescriptionAttachment_Get]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDescriptionAttachment_Get]    Script Date: 9/5/2018 9:47:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMTDescriptionAttachment_Get]
(
	@RQMTDescriptionAttachmentID BIGINT = 0,
	@RQMTDescriptionID INT = 0,
	@AttachmentID INT = 0,
	@IncludeData BIT = 0,
	@RQMTID INT = 0
)

AS
BEGIN

IF @IncludeData = 1
	SELECT
		rda.RQMTDescriptionAttachmentID,
		rda.RQMTDescriptionID,
		rda.AttachmentID,
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
		at.ATTACHMENTTYPE

	FROM RQMTDescriptionAttachment rda
		JOIN Attachment att ON (att.AttachmentId = rda.AttachmentID)
		JOIN AttachmentType at ON (at.AttachmentTypeId = att.AttachmentTypeId)
		JOIN RQMTDescription rd ON (rd.RQMTDescriptionID = rda.RQMTDescriptionID)
		LEFT JOIN RQMTSystemRQMTDescription rsrd ON (rsrd.RQMTDescriptionID = rd.RQMTDescriptionID)
		LEFT JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrd.RQMTSystemID)
	WHERE 
		(@RQMTDescriptionAttachmentID > 0 AND rda.RQMTDescriptionAttachmentID = @RQMTDescriptionAttachmentID)
		OR (@RQMTDescriptionID > 0 AND rda.RQMTDescriptionID = @RQMTDescriptionID)
		OR (@AttachmentID > 0 AND rda.AttachmentID = @AttachmentID)
		OR (@RQMTID > 0 AND rs.RQMTID = @RQMTID)
	ORDER BY
		att.FileName
ELSE
	SELECT
		rda.RQMTDescriptionAttachmentID,
		rda.RQMTDescriptionID,
		rda.AttachmentID,
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
		at.ATTACHMENTTYPE

	FROM RQMTDescriptionAttachment rda
		JOIN Attachment att ON (att.AttachmentId = rda.AttachmentID)
		JOIN AttachmentType at ON (at.AttachmentTypeId = att.AttachmentTypeId)
		JOIN RQMTDescription rd ON (rd.RQMTDescriptionID = rda.RQMTDescriptionID)
		LEFT JOIN RQMTSystemRQMTDescription rsrd ON (rsrd.RQMTDescriptionID = rd.RQMTDescriptionID)
		LEFT JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrd.RQMTSystemID)
	WHERE 
		(@RQMTDescriptionAttachmentID > 0 AND rda.RQMTDescriptionAttachmentID = @RQMTDescriptionAttachmentID)
		OR (@RQMTDescriptionID > 0 AND rda.RQMTDescriptionID = @RQMTDescriptionID)
		OR (@AttachmentID > 0 AND rda.AttachmentID = @AttachmentID)
		OR (@RQMTID > 0 AND rs.RQMTID = @RQMTID)
	ORDER BY
		att.FileName

END
GO


