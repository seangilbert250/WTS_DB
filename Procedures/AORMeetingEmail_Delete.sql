USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingEmail_Delete]    Script Date: 1/12/2018 10:28:56 AM ******/
if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingEmail_Delete]') and objectproperty(id, 'IsProcedure') = 1)
	DROP PROCEDURE [dbo].[AORMeetingEmail_Delete]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingEmail_Delete]    Script Date: 1/12/2018 10:28:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AORMeetingEmail_Delete]
(
	@AORMeetingID INT,
	@WTS_RESOURCEID INT = 0
)

AS

IF (@WTS_RESOURCEID = 0)
	DELETE FROM AORMeetingEmail WHERE AORMeetingID = @AORMeetingID
ELSE
	DELETE FROM AORMeetingEmail WHERE AORMeetingID = @AORMeetingID AND WTS_RESOURCEID = @WTS_RESOURCEID
GO


