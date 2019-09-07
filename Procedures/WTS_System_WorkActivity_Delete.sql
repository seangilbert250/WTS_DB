USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_WorkActivity_Delete]    Script Date: 3/29/2018 3:51:04 PM ******/
DROP PROCEDURE [dbo].[WTS_System_WorkActivity_Delete]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_WorkActivity_Delete]    Script Date: 3/29/2018 3:51:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WTS_System_WorkActivity_Delete]
	@WTS_SYSTEM_WORKACTIVITYID int, 
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(WTS_SYSTEM_WORKACTIVITYID)
	FROM WTS_SYSTEM_WORKACTIVITY
	WHERE 
		WTS_SYSTEM_WORKACTIVITYID = @WTS_SYSTEM_WORKACTIVITYID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM WTS_SYSTEM_WORKACTIVITY
		WHERE
			WTS_SYSTEM_WORKACTIVITYID = @WTS_SYSTEM_WORKACTIVITYID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO

