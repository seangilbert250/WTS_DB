USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_HasPreviousMeetingBeenAccepted]    Script Date: 4/23/2018 4:29:40 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstance_HasPreviousMeetingBeenAccepted]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_HasPreviousMeetingBeenAccepted]    Script Date: 4/23/2018 4:29:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AORMeetingInstance_HasPreviousMeetingBeenAccepted]
(
	@AORMeetingID INT,
	@AORMeetingInstanceID INT,
	@Accepted BIT OUTPUT,
	@LastMeetingInstanceID INT OUTPUT,
	@LastMeetingDate DATETIME OUTPUT
)
AS
BEGIN
	
	DECLARE @CurrentInstanceDate DATETIME = (SELECT InstanceDate FROM AORMeetingInstance WHERE AORMeetingInstanceID = @AORMeetingInstanceID)

	SELECT TOP 1 @Accepted = aormi.MeetingAccepted, @LastMeetingInstanceID = aormi.AORMeetingInstanceID, @LastMeetingDate = aormi.InstanceDate
		FROM AORMeetingInstance aormi
		WHERE aormi.AORMeetingID = @AORMeetingID AND aormi.InstanceDate < @CurrentInstanceDate
		ORDER BY aormi.InstanceDate DESC

END
GO


