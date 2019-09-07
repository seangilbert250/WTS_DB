USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Get_Contracts]    Script Date: 7/19/2018 3:24:19 PM ******/
DROP FUNCTION [dbo].[AOR_Get_Contracts]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Get_Contracts]    Script Date: 7/19/2018 3:24:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[AOR_Get_Contracts](
	@AORReleaseID int
)
RETURNS nvarchar(max)
AS
BEGIN
	DECLARE @Contracts nvarchar(max);

	SELECT @Contracts = Left(Main.Contracts, LEN(Main.Contracts)-1)
	From (
		SELECT (
			select a.CONTRACT + ', ' as [text()]
			from(
				select c.CONTRACTID
						, c.CONTRACT
				from AORRelease ar
				inner join AORReleaseTask art
				on ar.AORReleaseID = art.AORReleaseID
				inner join WORKITEM wi
				on art.WORKITEMID = wi.WORKITEMID
				inner join WTS_SYSTEM_CONTRACT wsc
				on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
				inner join CONTRACT c
				on wsc.CONTRACTID = c.CONTRACTID
				where ar.AORReleaseID = @AORReleaseID
				union
				select c.CONTRACTID
						, c.CONTRACT
				from AORRelease ar
				inner join AORReleaseSubTask arst
				on ar.AORReleaseID = arst.AORReleaseID
				inner join WORKITEM_TASK wt
				on arst.WORKITEMTASKID = wt.WORKITEM_TASKID
				inner join WORKITEM wi
				on wt.WORKITEMID = wi.WORKITEMID
				inner join WTS_SYSTEM_CONTRACT wsc
				on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
				inner join CONTRACT c
				on wsc.CONTRACTID = c.CONTRACTID
				where ar.AORReleaseID = @AORReleaseID
			) a
			order by CONTRACTID
			for xml path ('')
		) [Contracts]
	) [Main]
	
	RETURN @Contracts
END;
GO

