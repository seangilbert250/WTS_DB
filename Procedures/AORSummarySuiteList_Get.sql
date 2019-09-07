USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORSummarySuiteList_Get]    Script Date: 4/6/2018 9:15:05 AM ******/
DROP PROCEDURE [dbo].[AORSummarySuiteList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORSummarySuiteList_Get]    Script Date: 4/6/2018 9:15:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORSummarySuiteList_Get]
	@ProductVersion INT = 0
	, @Deliverable INT = 0
	, @Contract INT = 0
	, @IncludeArchive INT = 0
AS
BEGIN
	select distinct wss.WTS_SYSTEM_SUITEID,
		isnull(wss.WTS_SYSTEM_SUITE, '-') as WTS_SYSTEM_SUITE,
		wss.SORTORDER
	from AORRelease arl
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join ProductVersion pv
	on arl.ProductVersionID = pv.ProductVersionID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join AOR
	on arl.AORID = AOR.AORID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join WTS_SYSTEM_SUITE wss
	on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
	left join [CONTRACT] c
	on wsc.CONTRACTID = c.CONTRACTID
	left join AORReleaseDeliverable ard
	on arl.AORReleaseID = ard.AORReleaseID
	left join ReleaseSchedule rs
	on ard.DeliverableID = rs.ReleaseScheduleID
	where (isnull(@ProductVersion, 0) = 0 or pv.ProductVersionID = @ProductVersion)
	and (isnull(@Deliverable, 0) = 0 or rs.ReleaseScheduleID = @Deliverable)
	and (isnull(@Contract, 0) = 0 or c.CONTRACTID = @Contract)
	and isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	order by wss.SORTORDER
END;

GO


