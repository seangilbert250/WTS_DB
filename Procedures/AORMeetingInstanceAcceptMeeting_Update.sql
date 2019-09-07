USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAcceptMeeting_Update]    Script Date: 4/13/2018 4:50:44 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAcceptMeeting_Update]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAcceptMeeting_Update]    Script Date: 4/13/2018 4:50:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORMeetingInstanceAcceptMeeting_Update]
(
	@AORMeetingInstanceID INT,
	@Accept BIT,
	@UpdatedBy NVARCHAR(255) = 'WTS_ADMIN',
	@UpdatedDate DATETIME
)
AS
BEGIN

	UPDATE AORMeetingInstance
	SET
		MeetingAccepted = @Accept,
		UpdatedBy = @UpdatedBy,
		UpdatedDate = @UpdatedDate,
		Locked = (CASE WHEN @Accept = 1 THEN 1 ELSE Locked END),
		MeetingEnded = (CASE WHEN @Accept = 1 THEN 1 ELSE MeetingEnded END)
	WHERE
		AORMeetingInstanceID = @AORMeetingInstanceID
END
GO


