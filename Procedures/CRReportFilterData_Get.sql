USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[CRReportFilterData_Get]    Script Date: 4/27/2018 1:06:29 PM ******/
DROP PROCEDURE [dbo].[CRReportFilterData_Get]
GO

/****** Object:  StoredProcedure [dbo].[CRReportFilterData_Get]    Script Date: 4/27/2018 1:06:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[CRReportFilterData_Get]
	@FilterName nvarchar(255)
	, @Release nvarchar(255) = null
	, @AORType nvarchar(255) = null
	, @VisibleToCustomer nvarchar(255) = null
	, @Contract nvarchar(255) = null
	, @SystemSuite nvarchar(255) = null
	, @Deliverable nvarchar(255) = null
	, @WorkloadAllocation nvarchar(255) = null
AS
BEGIN 
	SELECT * FROM
	(
		SELECT DISTINCT 
			CASE @FilterName
				WHEN 'Release Version' THEN arl.ProductVersionID
				WHEN 'Deployment' THEN rs.ReleaseScheduleID
				WHEN 'AOR Workload Type' THEN arl.AORWorkTypeID
				WHEN 'Visible To Customer' THEN CASE arl.AORCustomerFlagship
												WHEN 'true' THEN 1
												WHEN 'false' THEN 0
											  END
				WHEN 'Contract' THEN wsc.CONTRACTID
				WHEN 'System Suite' THEN wss.WTS_SYSTEM_SUITEID
				WHEN 'Status' THEN s.STATUSID
				WHEN 'Workload Allocation' THEN arl.WorkloadAllocationID
			END AS FilterID
			, CASE @FilterName
				WHEN 'Release Version' THEN pv.ProductVersion
				WHEN 'Deployment' THEN pv.ProductVersion + '.' + rs.ReleaseScheduleDeliverable
				WHEN 'AOR Workload Type' THEN awt.AORWorkTypeName
				WHEN 'Visible To Customer' THEN CASE arl.AORCustomerFlagship
												WHEN 'true' THEN 'Yes'
												WHEN 'false' THEN 'No'
											  END
				WHEN 'Contract' THEN c.[CONTRACT]
				WHEN 'System Suite' THEN wss.WTS_SYSTEM_SUITE
				WHEN 'Status' THEN s.[STATUS]
				WHEN 'Workload Allocation' THEN ps.[WorkloadAllocation]
			END AS FilterValue
		FROM AORCR acr
		left join AORReleaseCR arc
			on acr.CRID = arc.CRID
		left join AORRelease arl
			on arc.AORReleaseID = arl.AORReleaseID
		left join [WorkloadAllocation] ps
			on arl.WorkloadAllocationID = ps.WorkloadAllocationID
		left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
		left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
		left join ProductVersion pv
			on arl.ProductVersionID = pv.ProductVersionID
		left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
		left join WTS_SYSTEM_CONTRACT wsc
			on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
		left join [CONTRACT] c
			on wsc.CONTRACTID = c.CONTRACTID
		left join [STATUS] s 
			on wi.STATUSID = s.STATUSID
		left join ReleaseSchedule rs
			on pv.ProductVersionID = rs.ProductVersionID
		left join WTS_SYSTEM ws
			on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		left join WTS_SYSTEM_SUITE wss
			on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
		where (isnull(@Release, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @Release + ',') > 0)
		and (isnull(@AORType, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.AORWorkTypeID, 0)) + ',', ',' + @AORType + ',') > 0)
		and (isnull(@VisibleToCustomer, '') = '' or charindex(',' + convert(nvarchar(10), arl.AORCustomerFlagship) + ',', ',' + @VisibleToCustomer + ',') > 0)
		and (isnull(@Contract, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsc.CONTRACTID, 0)) + ',', ',' + @Contract + ',') > 0)
		and (isnull(@SystemSuite, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wss.WTS_SYSTEM_SUITEID, 0)) + ',', ',' + @SystemSuite + ',') > 0)
		and (isnull(@Deliverable, '') = '' or charindex(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @Deliverable + ',') > 0)
		and (isnull(@WorkloadAllocation, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.WorkloadAllocationID, 0)) + ',', ',' + @WorkloadAllocation + ',') > 0)

	) t
	WHERE t.FilterID IS NOT NULL
	ORDER BY t.FilterValue
END;
GO

