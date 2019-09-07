USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WorkType_Resource_Add]    Script Date: 4/23/2018 1:03:43 PM ******/
DROP PROCEDURE [dbo].[WorkType_Resource_Add]
GO

/****** Object:  StoredProcedure [dbo].[WorkType_Resource_Add]    Script Date: 4/23/2018 1:03:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WorkType_Resource_Add]
	@WTS_RESOURCEID int,
	@WorkTypeID int,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;
	
	SELECT @exists = COUNT(*) FROM WorkType_WTS_RESOURCE WHERE WorkTypeID = @WorkTypeID AND WTS_RESOURCEID = @WTS_RESOURCEID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO WorkType_WTS_RESOURCE(
		WorkTypeID
		, WTS_RESOURCEID
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WorkTypeID
		, @WTS_RESOURCEID
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO

