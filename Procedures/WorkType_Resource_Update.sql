USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkType_Resource_Update]    Script Date: 4/23/2018 1:59:33 PM ******/
DROP PROCEDURE [dbo].[WorkType_Resource_Update]
GO

/****** Object:  StoredProcedure [dbo].[WorkType_Resource_Update]    Script Date: 4/23/2018 1:59:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[WorkType_Resource_Update]
	@WorkType_WTS_RESOURCEID int,
	@WTS_RESOURCEID int,
	@WorkTypeID int,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	DECLARE @exists int = 0;
	SET @saved = 0;

	SELECT @exists = COUNT(*) FROM WorkType_WTS_RESOURCE WHERE WorkTypeID = @WorkTypeID AND WTS_RESOURCEID = @WTS_RESOURCEID AND Archive = @Archive;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;
	
	IF ISNULL(@WorkType_WTS_RESOURCEID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WorkType_WTS_RESOURCE WHERE WorkType_WTS_RESOURCEID = @WorkType_WTS_RESOURCEID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					UPDATE WorkType_WTS_RESOURCE
					SET
						WorkTypeID = @WorkTypeID
						, WTS_RESOURCEID = @WTS_RESOURCEID
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkType_WTS_RESOURCEID = @WorkType_WTS_RESOURCEID;

					SET @saved = 1; 
				END;
		END;
END;

GO


