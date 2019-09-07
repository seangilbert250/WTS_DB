USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSession_Add]    Script Date: 6/1/2018 1:40:20 PM ******/
DROP PROCEDURE [dbo].[ReleaseSession_Add]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSession_Add]    Script Date: 6/1/2018 1:40:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ReleaseSession_Add]
	@ReleaseSession nvarchar(50),
	@SessionNarrative nvarchar(max),
	@PrimarySessionManagerID int = null,
	@SecondarySessionManagerID int = null,
	@ProductVersionID int,
	@StartDate date = null,
	@Duration int,
	@Sort int,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
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

	SELECT @exists = COUNT(*) FROM ReleaseSession WHERE [ReleaseSession] = @ReleaseSession and [ProductVersionID] = @ProductVersionID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO [dbo].[ReleaseSession]
           ([ReleaseSession]
		   ,SessionNarrative
		   ,PrimarySessionManagerID
		   ,SecondarySessionManagerID
           ,[ProductVersionID]
		   ,StartDate
		   ,Duration
		   ,[Sort]
           ,[ARCHIVE]
           ,[CREATEDBY]
           ,[CREATEDDATE]
           ,[UPDATEDBY]
           ,[UPDATEDDATE])
     VALUES
           (@ReleaseSession,
		    @SessionNarrative,
			@PrimarySessionManagerID,
			@SecondarySessionManagerID,
			@ProductVersionID,
			@StartDate,
			@Duration,
			@Sort,
			0,
			@CreatedBy,
			@date,
			@UpdatedBy,
			@date);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO

