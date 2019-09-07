USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Attachment_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Attachment_Get]

GO

CREATE PROCEDURE [dbo].[Attachment_Get]
	@AttachmentID int
AS
BEGIN
	SELECT
		a.AttachmentId
		, a.[FileName]
		, a.FileData
	FROM
		Attachment a
	WHERE
		AttachmentId = @AttachmentID
	;

END;

GO