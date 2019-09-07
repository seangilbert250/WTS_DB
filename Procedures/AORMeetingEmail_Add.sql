USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingEmail_Add]    Script Date: 1/12/2018 10:28:51 AM ******/
if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingEmail_Add]') and objectproperty(id, 'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[AORMeetingEmail_Add]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingEmail_Add]    Script Date: 1/12/2018 10:28:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AORMeetingEmail_Add]
(
	@AORMeetingID INT,
	@WTS_RESOURCEID INT,
	@WTS_RESOURCEIDS VARCHAR(2000)
)

AS

IF @WTS_RESOURCEID <> 0 AND NOT EXISTS (SELECT 1 FROM AORMeetingEmail WHERE AORMeetingID = @AORMeetingID AND WTS_RESOURCEID = @WTS_RESOURCEID)
	INSERT INTO AORMeetingEmail (AORMeetingID, WTS_RESOURCEID) VALUES (@AORMeetingID, @WTS_RESOURCEID)

IF @WTS_RESOURCEIDS IS NOT NULL
BEGIN
	INSERT INTO AORMeetingEmail (AORMeetingID, WTS_RESOURCEID)
		SELECT DISTINCT @AORMeetingID, Data
		FROM dbo.Split(@WTS_RESOURCEIDS, ',')
END
GO


