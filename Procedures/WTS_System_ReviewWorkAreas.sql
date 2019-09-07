USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_ReviewWorkAreas]    Script Date: 8/21/2018 1:21:09 PM ******/
DROP PROCEDURE [dbo].[WTS_System_ReviewWorkAreas]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_ReviewWorkAreas]    Script Date: 8/21/2018 1:21:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WTS_System_ReviewWorkAreas]
	@WTS_SystemID int,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;

	IF ISNULL(@WTS_SystemID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WTS_System WHERE WTS_SystemID = @WTS_SystemID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WTS_System
					SET
						WorkAreasReviewedBy = @UpdatedBy
						, WorkAreasReviewedDate = @date
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WTS_SystemID = @WTS_SystemID;
				END;

			SET @saved = 1; 

		END;
END;
