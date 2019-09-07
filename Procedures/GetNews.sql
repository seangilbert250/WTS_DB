USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[GetNews]    Script Date: 7/18/2018 3:31:33 PM ******/
DROP PROCEDURE [dbo].[GetNews]
GO

/****** Object:  StoredProcedure [dbo].[GetNews]    Script Date: 7/18/2018 3:31:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===================================================
-- Author:		Steve Badgley
-- Create date: 1/11/2017
-- Description:	Get latest WTS updates from News table
-- ===================================================
CREATE PROCEDURE [dbo].[GetNews]
	  @NewsID int = null
	,@NewsTypeID int = null
	, @SysNotification int = 0
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();

	if @SysNotification = 0
			BEGIN
				SELECT * FROM (
					SELECT '' AS X
						 , n.NewsID
						 , Convert(varchar(10),Start_Date, 101) as Start_Date
						 , Convert(varchar(10),End_Date, 101) as End_Date
						 , Summary
						 , Detail 
						 , isnull(Bln_News, 1) as Bln_News
						 , isnull(Bln_Active,0) as Bln_Active
						 , nt.NewsType
						 , n.NewsTypeID
						 , Sort_Order
						 , '' AS Y
					FROM News n
					left join NewsType nt 
					ON n.NewsTypeID = nt.NewsTypeID
					WHERE (isnull(@NewsID, 0) = 0 or n.NewsID = @NewsID)
					AND isnull(Bln_Archive,0) = 0
				) news
				ORDER BY news.NewsID;
			END
	ELSE
		SELECT Convert(varchar(10),Start_Date, 101) + '-' + Convert(varchar(10),End_Date, 101) as Date
			 , Summary
		FROM News
		WHERE isnull(Bln_Archive,0) = 0
		and @date between Start_Date and End_Date
		ORDER BY NewsID;
END

GO


