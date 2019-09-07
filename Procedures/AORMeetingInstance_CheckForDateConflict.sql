USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_CheckForDateConflict]    Script Date: 3/14/2018 10:26:57 AM ******/
DROP PROCEDURE [dbo].[AORMeetingInstance_CheckForDateConflict]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_CheckForDateConflict]    Script Date: 3/14/2018 10:26:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORMeetingInstance_CheckForDateConflict]
(
	@AORMeetingID INT,
	@AORMeetingInstanceID INT,
	@InstanceDate DATETIME,
	@Conflict INT = 0 OUTPUT
)
AS
BEGIN
	SET @Conflict =
	(
		SELECT
			ami.AORMeetingInstanceID
		FROM 
			AORMeetingInstance ami
		WHERE
			ami.AORMeetingID = @AORMeetingID
			AND ami.AORMeetingInstanceID <> @AORMeetingInstanceID
			AND ami.InstanceDate = @InstanceDate
	)
END
GO


