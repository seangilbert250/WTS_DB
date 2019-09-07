USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAOR_Add]    Script Date: 3/13/2018 11:10:18 AM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAOR_Add]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAOR_Add]    Script Date: 3/13/2018 11:10:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORMeetingInstanceAOR_Add]
(
	@AORMeetingID int = 28,
	@AORMeetingInstanceID int = 807,
	@AORID int = 177,
	@AddedBy nvarchar(50) = 'WTS',
	@AORReleaseID int OUTPUT
)
AS
BEGIN
	DECLARE @dt DATETIME = GETDATE()

	SET @AORReleaseID = 
		(
			SELECT 
				MAX(arl.AORReleaseID)
			FROM 
				AOR aor
				JOIN AORRelease arl ON (arl.AORID = aor.AORID)
			WHERE 
				aor.AORID = @AORID
				AND arl.[Current] = 1
		)

	IF NOT EXISTS (SELECT 1 FROM AORMeetingAOR WHERE AORMeetingID = @AORMeetingID AND AORMeetingInstanceID_Add = @AORMeetingInstanceID AND AORReleaseID = @AORReleaseID)
	BEGIN
		INSERT INTO AORMeetingAOR(AORMeetingID, AORReleaseID, AORMeetingInstanceID_Add, AddDate, AORMeetingInstanceID_Remove, RemoveDate, Archive, CreatedBy, CreatedDate)
		VALUES
		(
			@AORMeetingID,
			@AORReleaseID,
			@AORMeetingInstanceID,
			@dt,
			NULL,
			NULL,
			0,
			@AddedBy,
			@dt
		)
	END
END
GO


