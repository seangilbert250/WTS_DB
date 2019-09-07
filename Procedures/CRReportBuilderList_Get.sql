USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[CRReportBuilderList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [CRReportBuilderList_Get]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CRReportBuilderList_Get]
	@ReleaseID INT = 0,
	@ContractID INT = 0,
	@VisibleToCustomer BIT = 1
AS
BEGIN
	SELECT 
		cr.CRID
		, cr.CRName
		, isnull(cr.ITIPriority, 9999) as Sort
		, isnull(cr.PrimarySR, 0) as PrimarySR
	FROM AORCR cr
	left join AORReleaseCR arc on cr.CRID = arc.CRID 
	left join AORRelease arl on arc.AORReleaseID = arl.AORReleaseID 
	left join AOR on arl.AORID = AOR.AORID
	WHERE isnull(arl.[Current], 1) = 1 
	and cr.Archive = 0
	and isnull(AOR.Archive, 0) = 0
	and isnull(cr.StatusID, 0) != 104
	GROUP BY cr.CRID, cr.CRName, cr.ITIPriority, cr.PrimarySR
	ORDER BY cr.CRName;

	select *
	from (
		SELECT 
		arl.AORID
		, arl.AORName
		, arl.AORReleaseID
		, cr.CRName
		, cr.CRID
		, isnull(arl.WorkloadAllocationID, 0) as WorkloadAllocationID
		, arl.AORCustomerFlagship as VisibleToCustomer
		, isnull(cr.ITIPriority, 9999) as Sort
		, isnull(cr.PrimarySR, 0) as PrimarySR
		FROM AORCR cr
			left join AORReleaseCR arc
			on cr.CRID = arc.CRID
			left join AORRelease arl
			on arc.AORReleaseID = arl.AORReleaseID
			left join AOR 
			on arl.AORID = AOR.AORID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			join AORReleaseSystem ars
			on arl.AORReleaseID = ars.AORReleaseID
		WHERE isnull(wsc.[Primary], 1) = 1
			and ars.[Primary] = 1
			and cr.Archive = 0
			and isnull(AOR.Archive, 0) = 0
			and arl.AORCustomerFlagship in (@VisibleToCustomer, 1)
			and wsc.CONTRACTID = @ContractID
			and arl.ProductVersionID = @ReleaseID
			and isnull(awt.AORWorkTypeID, 2) = 2
		GROUP BY arl.AORID, arl.AORReleaseID, arl.AORName, arl.AORReleaseID, cr.CRName, cr.CRID, arl.WorkloadAllocationID, arl.AORCustomerFlagship, cr.ITIPriority, cr.PrimarySR
		union 
		SELECT 
			arl.AORID
			, arl.AORName
			, arl.AORReleaseID
			, '' as CRName
			, -9999 as CRID
			, isnull(arl.WorkloadAllocationID, 0) as WorkloadAllocationID
			, arl.AORCustomerFlagship as VisibleToCustomer
			, 9999 as Sort
			, 0 as PrimarySR
		FROM AORRelease arl
			left join AOR 
			on arl.AORID = AOR.AORID
			left join AORReleaseCR arc
			on arl.AORReleaseID = arc.AORReleaseID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join AORReleaseTask art
			on arl.AORReleaseID = art.AORReleaseID
			left join WORKITEM wi
			on art.WORKITEMID = wi.WORKITEMID
			left join WTS_SYSTEM_CONTRACT wsc
			on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
			join AORReleaseSystem ars
			on arl.AORReleaseID = ars.AORReleaseID
		WHERE isnull(wsc.[Primary], 1) = 1
			and ars.[Primary] = 1
			and isnull(AOR.Archive, 0) = 0
			and arl.AORCustomerFlagship in (@VisibleToCustomer, 1)
			and wsc.CONTRACTID = @ContractID
			and arl.ProductVersionID = @ReleaseID
			and isnull(awt.AORWorkTypeID, 2) = 2
			and arc.CRID is null
		GROUP BY arl.AORID, arl.AORName, arl.AORReleaseID, arl.WorkloadAllocationID, arl.AORCustomerFlagship
	) a
	ORDER BY 
	a.AORID

	SELECT arl.AORID,
		rs.ReleaseScheduleID as DeploymentID,
		rs.ReleaseScheduleDeliverable,
		rs.[Description],
		isnull(convert(nvarchar(10),MIN(rs.[PlannedEnd])), '9999') as ScheduledDate
	FROM ReleaseSchedule rs
		left join AORReleaseDeliverable ard
		on rs.ReleaseScheduleID = ard.DeliverableID
		left join AORRelease arl
		on ard.AORReleaseID = arl.AORReleaseID
		left join DeploymentContract dc
		on rs.ReleaseScheduleID = dc.DeliverableID
	WHERE isnull(arl.AORCustomerFlagship, 1) in (@VisibleToCustomer, 1)
		and (isnull(@ContractID, 0) = 0 or dc.CONTRACTID = @ContractID)
		and (isnull(@ReleaseID, 0) = 0 or rs.ProductVersionID = @ReleaseID)
	GROUP BY arl.AORID, rs.ReleaseScheduleID, rs.ReleaseScheduleDeliverable, rs.[Description]
	order by rs.ReleaseScheduleDeliverable

END;

GO
