USE [WTS]
GO

DROP PROCEDURE [dbo].[NewsAttachment_Delete]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NewsAttachment_Delete]
	@NewsAttachmentId int,
	@deleted bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @EXISTS int = 0;


	update dbo.Attachment
	set Archive = 1
	where AttachmentID = @NewsAttachmentId
	;

	SET @deleted = 1;
END;
GO

