USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_WorkActivity_Add]    Script Date: 3/29/2018 3:25:03 PM ******/
DROP PROCEDURE [dbo].[WTS_System_WorkActivity_Add]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_WorkActivity_Add]    Script Date: 3/29/2018 3:25:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WTS_System_WorkActivity_Add]
	@WTS_SYSTEMID int,
	@WorkItemTypeID int,
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
	
	SELECT @exists = COUNT(*) FROM WTS_SYSTEM_WORKACTIVITY WHERE WTS_SYSTEMID = @WTS_SYSTEMID AND WorkItemTypeID = @WorkItemTypeID;
		IF (ISNULL(@exists,0) > 0)
			BEGIN
				RETURN;
			END;
		INSERT INTO WTS_SYSTEM_WORKACTIVITY(
			WorkItemTypeID
			, WTS_SYSTEMID
			, Archive
			, CreatedBy
			, CreatedDate
			, UpdatedBy
			, UpdatedDate
		)
		VALUES(
			@WorkItemTypeID
			, @WTS_SYSTEMID
			, 0
			, @CreatedBy
			, @date
			, @CreatedBy
			, @date
		);
		SELECT @newID = SCOPE_IDENTITY();
END;

GO
