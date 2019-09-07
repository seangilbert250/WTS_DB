USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceResource_Update]    Script Date: 5/14/2018 11:59:44 AM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceResource_Update]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceResource_Update]    Script Date: 5/14/2018 11:59:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORMeetingInstanceResource_Update]
(
	@AORMeetingID INT,
	@AORMeetingInstanceID INT,
	@WTS_RESOURCEID INT,
	@Attended BIT,
	@ReasonForAttending NVARCHAR(500) NULL,
	@CreatedBy NVARCHAR(255),
	@UpdatedBy NVARCHAR(255)
)
AS
BEGIN
	DECLARE @now DATETIME = GETDATE()

	IF @Attended = 1
	BEGIN
		IF EXISTS (SELECT 1 FROM AORMeetingResourceAttendance WHERE AORMeetingInstanceID = @AORMeetingInstanceID AND WTS_RESOURCEID = @WTS_RESOURCEID)
		BEGIN
			UPDATE AORMeetingResourceAttendance SET ReasonForAttending = @ReasonForAttending, UpdatedBy = @UpdatedBy, UpdatedDate = @now
				WHERE AORMeetingInstanceID = @AORMeetingInstanceID AND WTS_RESOURCEID = @WTS_RESOURCEID 
		END
		ELSE
		BEGIN
			INSERT INTO AORMeetingResourceAttendance VALUES (@AORMeetingInstanceID, @WTS_RESOURCEID, @ReasonForAttending, 0, @CreatedBy, @now, @UpdatedBy, @now)
		END
	END
	ELSE
	BEGIN
		DELETE FROM AORMeetingResourceAttendance WHERE AORMeetingInstanceID = @AORMeetingInstanceID AND WTS_RESOURCEID = @WTS_RESOURCEID
	END
END
GO


