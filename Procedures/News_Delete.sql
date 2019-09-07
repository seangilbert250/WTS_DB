USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[News_Delete]    Script Date: 7/17/2018 3:30:14 PM ******/
DROP PROCEDURE [dbo].[News_Delete]
GO

/****** Object:  StoredProcedure [dbo].[News_Delete]    Script Date: 7/17/2018 3:30:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[News_Delete]
	@NewsId int,
	@ArchivedBy nvarchar(255) = 'WTS_Admin',
	@deleted bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @EXISTS int = 0;


	update dbo.News
	set Bln_Archive = 1
		, Updated_By = @ArchivedBy
		, Updated_Date = @date
	where NewsID = @NewsId
	;

	SET @deleted = 1;
END;
GO

