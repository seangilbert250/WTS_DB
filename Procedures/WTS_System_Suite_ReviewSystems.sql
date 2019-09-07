USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_Suite_ReviewSystems]    Script Date: 8/21/2018 1:21:09 PM ******/
DROP PROCEDURE [dbo].[WTS_System_Suite_ReviewSystems]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_Suite_ReviewSystems]    Script Date: 8/21/2018 1:21:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WTS_System_Suite_ReviewSystems]
	@WTS_System_SuiteID int,
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

	IF ISNULL(@WTS_System_SuiteID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WTS_SYSTEM_SUITE WHERE WTS_SYSTEM_SUITEID = @WTS_System_SuiteID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WTS_SYSTEM_SUITE
					SET
						SystemsReviewedBy = @UpdatedBy
						, SystemsReviewedDate = @date
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WTS_SYSTEM_SUITEID = @WTS_System_SuiteID;
				END;

			SET @saved = 1; 

		END;
END;
