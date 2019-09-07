USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WorkItem_Task_GetAttachmentList]    Script Date: 10/25/2017 4:33:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkItem_Task_GetAttachmentList]
	@WorkItemTaskID int = 0
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
			JOIN WorkItem_Task_Attachment wa ON a.AttachmentId = wa.AttachmentId
			--LEFT JOIN Attachment_Extension ae ON a.ExtensionID = ae.AttachmentExtensionId
	WHERE
		wa.WORKITEM_TASKID = @WorkItemTaskID
	ORDER BY
		UPPER(a.[FileName])
	;


END;

