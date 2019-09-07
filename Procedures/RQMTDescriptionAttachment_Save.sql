USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDescriptionAttachment_Save]    Script Date: 9/4/2018 4:48:12 PM ******/
DROP PROCEDURE [dbo].[RQMTDescriptionAttachment_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDescriptionAttachment_Save]    Script Date: 9/4/2018 4:48:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RQMTDescriptionAttachment_Save]
(
    @RQMTDescriptionAttachmentID INT,
    @RQMTDescriptionID INT,
    @AttachmentID INT
)
AS
BEGIN
	IF @RQMTDescriptionAttachmentID = 0
		INSERT INTO RQMTDescriptionAttachment VALUES (@RQMTDescriptionID, @AttachmentID)
	ELSE
		UPDATE RQMTDescriptionAttachment
		SET
			RQMTDescriptionID = @RQMTDescriptionID,
			AttachmentID = @AttachmentID
		WHERE
			RQMTDescriptionAttachmentID = @RQMTDescriptionAttachmentID
END
GO


