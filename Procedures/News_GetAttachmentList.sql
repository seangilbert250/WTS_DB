USE [WTS]
GO


DROP PROCEDURE [dbo].[News_GetAttachmentList]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[News_GetAttachmentList]
	@NEWSID int = 0
	, @ShowArchived BIT = 0
AS
BEGIN

	SELECT
		a.AttachmentId
		, a.[FileName]
		, a.AttachmentTypeId
		, at.AttachmentType
		, a.Title
		, a.[Description]
		, a.CREATEDBY
		, a.CREATEDDATE
	FROM
		Attachment a
			JOIN AttachmentType at ON a.AttachmentTypeId = at.AttachmentTypeId
			JOIN News_Attachment na ON a.AttachmentId = na.AttachmentId
	WHERE
		na.NewsId = @NEWSID
		and a.Archive = isnull(@ShowArchived, 0)
	ORDER BY
		UPPER(a.[FileName]);

END;

GO


