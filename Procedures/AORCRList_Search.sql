USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORCRList_Search]    Script Date: 3/19/2018 10:47:24 AM ******/
DROP PROCEDURE [dbo].[AORCRList_Search]
GO

/****** Object:  StoredProcedure [dbo].[AORCRList_Search]    Script Date: 3/19/2018 10:47:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AORCRList_Search]
	@PrimarySR int = 0
as
begin
	select CRID,
		CRName
	from AORCR
	where Archive = 0
	and PrimarySR = @PrimarySR
	order by CRID DESC;
end;

GO


