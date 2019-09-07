USE [WTS]
GO

DROP PROCEDURE [dbo].[GetCurrentNewsOverviewAttachmentID]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetCurrentNewsOverviewAttachmentID]
	@NewsOverviewAttachmentID int = 0 output
AS
BEGIN


	SELECT top 1 @NewsOverviewAttachmentID = a.AttachmentId from news n

	left join NewsType nt
	on n.NewsTypeID = nt.NewsTypeID 
	left join News_Attachment na
	on na.NewsId = n.NewsID
	left join Attachment a
	on a.AttachmentId = na.AttachmentId
	where nt.NewsType = 'News Overview'
	and n.Bln_Archive = 0
	AND Start_Date >= dateadd(day, 1-datepart(dw, getdate()), CONVERT(date,getdate())) 
	AND Start_Date <  dateadd(day, 8-datepart(dw, getdate()), CONVERT(date,getdate()))

END
GO

