USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_ToggleMeetingLock]    Script Date: 4/17/2018 4:52:06 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstance_ToggleMeetingLock]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_ToggleMeetingLock]    Script Date: 4/17/2018 4:52:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORMeetingInstance_ToggleMeetingLock]
(
	@AORMeetingInstanceID INT,
	@Locked BIT,
	@UnlockReason NVARCHAR(MAX),
	@WTS_RESOURCEID INT
)
AS
BEGIN
	IF @Locked = 1
		UPDATE AORMeetingInstance SET Locked = 1, UnlockedReason = NULL, UnlockedByID = NULL, UnlockedDate = NULL WHERE AORMeetingInstanceID = @AORMeetingInstanceID AND Locked = 0
	ELSE
		UPDATE AORMeetingInstance SET Locked = 0, MeetingAccepted = 0, UnlockedReason = @UnlockReason, UnlockedByID = @WTS_RESOURCEID, UnlockedDate = GETDATE() WHERE AORMeetingInstanceID = @AORMeetingInstanceID AND Locked = 1
END
GO


