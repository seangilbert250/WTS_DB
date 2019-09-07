USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkType_Resource_Delete]    Script Date: 4/23/2018 1:35:07 PM ******/
DROP PROCEDURE [dbo].[WorkType_Resource_Delete]
GO

/****** Object:  StoredProcedure [dbo].[WorkType_Resource_Delete]    Script Date: 4/23/2018 1:35:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkType_Resource_Delete]
	@WorkType_WTS_RESOURCEID int, 
	@exists int output,
	@hasDependencies int output,
	@deleted int output,
	@archived int output
AS
BEGIN
	SET @exists = 0;
	SET @hasDependencies = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(WorkType_WTS_RESOURCEID)
	FROM WorkType_WTS_RESOURCE
	WHERE 
		WorkType_WTS_RESOURCEID = @WorkType_WTS_RESOURCEID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM WorkType_WTS_RESOURCE
		WHERE
			WorkType_WTS_RESOURCEID = @WorkType_WTS_RESOURCEID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END

