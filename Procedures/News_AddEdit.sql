USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[News_AddEdit]    Script Date: 7/17/2018 3:30:01 PM ******/
DROP PROCEDURE [dbo].[News_AddEdit]
GO

/****** Object:  StoredProcedure [dbo].[News_AddEdit]    Script Date: 7/17/2018 3:30:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[News_AddEdit]
	@NewsId int = null,
	@NewsTypeId int = null,
	@ArticleTitle nvarchar(50),
	@NotificationType  int,
	@StartDate nvarchar(10),
	@EndDate nvarchar(10),
	@Active bit,
	@Description nvarchar(max),
	@CreatedBy nvarchar(255) = 'WTS_Admin',
	@saved bit output,
	@NewID int = 0 output,
	@EXISTS bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		SET NOCOUNT ON;
	SET @EXISTS = 0
	DECLARE @date datetime = GETDATE();

	if (@newsid = -1)
		insert into dbo.News(
			  [Summary]
			, [Detail]
			, [NewsTypeID]
			, [Start_Date]
			, [End_Date]
			, [Bln_Active]
			, [Bln_News]
			, [Created_By]
			, [Created_Date]
			, [Updated_By]
			, [Updated_Date]
		)
		values(
			@ArticleTitle
			, @Description
			, @NewsTypeId
			, convert(datetime, @StartDate)
			, convert(datetime, @EndDate)
			, @Active
			, @NotificationType
			, @CreatedBy
			, @date
			, @CreatedBy
			, @date
		);
	else
		BEGIN
			select @EXISTS = count(*) from news where newsid = @Newsid;
			select @NewID = Newsid from news where newsid = @Newsid;
			if (@exists > 0)
			update dbo.news
			set [Summary] = @ArticleTitle
				, [Detail] = @Description
				, [NewsTypeId] = @NewsTypeId
				, [Start_Date] = convert(datetime, @StartDate)
				, [End_Date] = convert(datetime, @EndDate)
				, [Bln_Active] = @Active
				, [Bln_News] = @NotificationType
				, [Created_By] = @CreatedBy
				, [Created_Date] = @date
				, [Updated_By] = @CreatedBy
				, [Updated_Date] = @date
			where NewsID = @newsid
			--and NewsTypeID = @NewsTypeId;
			--select @AttachmentID = attachmentID from News_Attachment where NewsId = @NewsId

		END

	if (@newsid = -1)
		begin
			select @NewID = scope_identity();
		end

	SET @saved = 1;
END;
GO

