USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_GetAttachmentList]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_GetAttachmentList]

GO

CREATE PROCEDURE [dbo].[WorkItem_GetAttachmentList]
	@WORKITEMID int = 0
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
			JOIN WorkItem_Attachment wa ON a.AttachmentId = wa.AttachmentId
			--LEFT JOIN Attachment_Extension ae ON a.ExtensionID = ae.AttachmentExtensionId
	WHERE
		wa.WorkItemId = @WORKITEMID
	ORDER BY
		UPPER(a.[FileName])
	;


END;

GO
