USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSession_Update]    Script Date: 6/1/2018 3:06:41 PM ******/
DROP PROCEDURE [dbo].[ReleaseSession_Update]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSession_Update]    Script Date: 6/1/2018 3:06:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ReleaseSession_Update]
	@ReleaseSessionID int,
	@ReleaseSession nvarchar(50),
	@SessionNarrative nvarchar(max),
	@PrimarySessionManagerID int = null,
	@SecondarySessionManagerID int = null,
	@ProductVersionID int,
	@StartDate date = null,
	@Duration int,
	@Sort int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();

	UPDATE [dbo].[ReleaseSession]
	SET
		[ReleaseSession] = @ReleaseSession
		,[SessionNarrative] = @SessionNarrative
        ,[PrimarySessionManagerID] = @PrimarySessionManagerID
        ,[SecondarySessionManagerID] = @SecondarySessionManagerID
        ,[ProductVersionID] = @ProductVersionID
        ,[StartDate] = @StartDate
        ,[Duration] = @Duration
		,[Sort] = @Sort
        ,[ARCHIVE] = @Archive
        ,[UPDATEDBY] = @UpdatedBy
        ,[UPDATEDDATE] = @date
	WHERE ReleaseSessionID = @ReleaseSessionID

	SET @saved = 1;

END;

GO

