USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_GetAttachmentList]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_GetAttachmentList]

GO

CREATE PROCEDURE [dbo].[WorkRequest_GetAttachmentList]
	@WorkRequestID int = 0
	, @ShowArchived BIT = 0
AS
BEGIN
	SELECT
		a.AttachmentId
		, a.[FileName]
		, a.AttachmentTypeId
		, at.AttachmentType
		--, ae.Extension
		--, ae.FileIconID
		, a.Title
		, a.[Description]
		, a.CREATEDBY
		, a.CREATEDDATE
	FROM
		Attachment a
			JOIN AttachmentType at ON a.AttachmentTypeId = at.AttachmentTypeId
			JOIN WorkRequest_Attachment wa ON a.AttachmentId = wa.AttachmentId
			--LEFT JOIN Attachment_Extension ae ON a.ExtensionID = ae.AttachmentExtensionId
	WHERE
		wa.WorkRequestId = @WorkRequestID
	ORDER BY
		UPPER(a.[FileName])
	;


END;

GO
