USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDescriptionAttachment_Delete]    Script Date: 9/5/2018 10:24:57 AM ******/
DROP PROCEDURE [dbo].[RQMTDescriptionAttachment_Delete]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDescriptionAttachment_Delete]    Script Date: 9/5/2018 10:24:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMTDescriptionAttachment_Delete]
(
	@RQMTDescriptionAttachmentID BIGINT = 0,
	@RQMTDescriptionID INT = 0,
	@AttachmentID INT = 0
)

AS

DELETE FROM RQMTDescriptionAttachment 
WHERE 
	RQMTDescriptionAttachmentID = @RQMTDescriptionAttachmentID
	OR (@RQMTDescriptionID > 0 AND RQMTDescriptionID = @RQMTDescriptionID)
	OR (@AttachmentID > 0 AND AttachmentID = @AttachmentID)

DELETE FROM Attachment WHERE AttachmentID = @AttachmentID




GO


