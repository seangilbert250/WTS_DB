USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[MassChangeTaskList_Get]    Script Date: 5/18/2018 12:32:09 PM ******/
DROP PROCEDURE [dbo].[MassChangeTaskList_Get]
GO

/****** Object:  StoredProcedure [dbo].[MassChangeTaskList_Get]    Script Date: 5/18/2018 12:32:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[MassChangeTaskList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0
as
begin
	with w_TaskAOR_WorkType as (
			select wi.WORKITEMID,
				AOR.AORID,
				AOR.AORName,
				arl.AORReleaseID,
				isnull(rta.CascadeAOR, 0) as CascadeAOR,
				isnull(awt.AORWorkTypeName, 'No AOR Type') as AORType,
				isnull(arl.AORWorkTypeID,-1) as AORWorkTypeID,
				invs.[STATUS] as InvestigationStatus,
				invs.SORT_ORDER as InvestigationStage,
				invs.StatusTypeID as InvestigationStatusTypeID,
				ts.[STATUS] as TechnicalStatus,
				ts.SORT_ORDER as TechnicalStage,
				ts.StatusTypeID as TechnicalStatusTypeID,
				cds.[STATUS] as CustomerDesignStatus,
				cds.SORT_ORDER as CustomerDesignStage,
				cds.StatusTypeID as CustomerDesignStatusTypeID,
				cods.[STATUS] as CodingStatus,
				cods.SORT_ORDER as CodingStage,
				cods.StatusTypeID as CodingStatusTypeID,
				its.[STATUS] as InternalTestingStatus,
				its.SORT_ORDER as InternalTestingStage,
				its.StatusTypeID as InternalTestingStatusTypeID,
				cvts.[STATUS] as CustomerValidationTestingStatus,
				cvts.SORT_ORDER as CustomerValidationTestingStage,
				cvts.StatusTypeID as CustomerValidationTestingStatusTypeID,
				ads.[STATUS] as AdoptionStatus,
				ads.SORT_ORDER as AdoptionStage,
				ads.StatusTypeID as AdoptionStatusTypeID
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask rta
			on arl.AORReleaseID = rta.AORReleaseID
			join WORKITEM wi
			on rta.WORKITEMID = wi.WORKITEMID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join [STATUS] invs
			on arl.InvestigationStatusID = invs.STATUSID
			left join [STATUS] ts
			on arl.TechnicalStatusID = ts.STATUSID
			left join [STATUS] cds
			on arl.CustomerDesignStatusID = cds.STATUSID
			left join [STATUS] cods
			on arl.CodingStatusID = cods.STATUSID
			left join [STATUS] its
			on arl.InternalTestingStatusID = its.STATUSID
			left join [STATUS] cvts
			on arl.CustomerValidationTestingStatusID = cvts.STATUSID
			left join [STATUS] ads
			on arl.AdoptionStatusID = ads.STATUSID
			where arl.[Current] = 1
			and AOR.Archive = 0
		),
		w_SubTaskAOR_WorkType as (
			select wi.WORKITEM_TASKID,
			AOR.AORID,
			AOR.AORName,
			arl.AORReleaseID,
			isnull(rta.CascadeAOR, 0) as CascadeAOR,
			isnull(awt.AORWorkTypeName, 'No AOR Type') as AORType,
			isnull(arl.AORWorkTypeID,-1) as AORWorkTypeID,
			invs.[STATUS] as InvestigationStatus,
			invs.SORT_ORDER as InvestigationStage,
			invs.StatusTypeID as InvestigationStatusTypeID,
			ts.[STATUS] as TechnicalStatus,
			ts.SORT_ORDER as TechnicalStage,
			ts.StatusTypeID as TechnicalStatusTypeID,
			cds.[STATUS] as CustomerDesignStatus,
			cds.SORT_ORDER as CustomerDesignStage,
			cds.StatusTypeID as CustomerDesignStatusTypeID,
			cods.[STATUS] as CodingStatus,
			cods.SORT_ORDER as CodingStage,
			cods.StatusTypeID as CodingStatusTypeID,
			its.[STATUS] as InternalTestingStatus,
			its.SORT_ORDER as InternalTestingStage,
			its.StatusTypeID as InternalTestingStatusTypeID,
			cvts.[STATUS] as CustomerValidationTestingStatus,
			cvts.SORT_ORDER as CustomerValidationTestingStage,
			cvts.StatusTypeID as CustomerValidationTestingStatusTypeID,
			ads.[STATUS] as AdoptionStatus,
			ads.SORT_ORDER as AdoptionStage,
			ads.StatusTypeID as AdoptionStatusTypeID
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseSubTask rsta
			on arl.AORReleaseID = rsta.AORReleaseID
			join WORKITEM_TASK wi
			on rsta.WORKITEMTASKID = wi.WORKITEM_TASKID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join AORReleaseTask rta
			on arl.AORReleaseID = rta.AORReleaseID
			and wi.WORKITEMID = rta.WORKITEMID
			left join [STATUS] invs
			on arl.InvestigationStatusID = invs.STATUSID
			left join [STATUS] ts
			on arl.TechnicalStatusID = ts.STATUSID
			left join [STATUS] cds
			on arl.CustomerDesignStatusID = cds.STATUSID
			left join [STATUS] cods
			on arl.CodingStatusID = cods.STATUSID
			left join [STATUS] its
			on arl.InternalTestingStatusID = its.STATUSID
			left join [STATUS] cvts
			on arl.CustomerValidationTestingStatusID = cvts.STATUSID
			left join [STATUS] ads
			on arl.AdoptionStatusID = ads.STATUSID
			where arl.[Current] = 1
			and AOR.Archive = 0
		),
		w_filtered_sub_tasks as (
			select wit.*, s.[STATUS],s.[SORT_ORDER] as StatusStage, p.[PRIORITY], ao.ORGANIZATION,
			tawt.AORID,
			tawt.AORName,
			tawt.AORReleaseID,
			convert(int, rta.CascadeAOR) as CascadeAOR,
			tawt. AORType,
			tawt.InvestigationStage,
			tawt.TechnicalStage,
			tawt.CustomerDesignStage,
			tawt.CodingStage,
			tawt.InternalTestingStage,
			tawt.CustomerValidationTestingStage,
			tawt.AdoptionStage,
			tawt2.AORID as AORID2,
			tawt2.AORName as AORName2,
			tawt2.AORReleaseID as AORReleaseID2,
			convert(int, rta.CascadeAOR) as CascadeAOR2,
			tawt2.AORType as AORType2,
			tawt2.InvestigationStage as InvestigationStage2,
			tawt2.TechnicalStage as TechnicalStage2,
			tawt2.CustomerDesignStage as CustomerDesignStage2,
			tawt2.CodingStage as CodingStage2,
			tawt2.InternalTestingStage as InternalTestingStage2,
			tawt2.CustomerValidationTestingStage as CustomerValidationTestingStage2,
			tawt2.AdoptionStage as AdoptionStage2
			from WORKITEM_TASK wit
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join [STATUS] s
			on wit.STATUSID = s.STATUSID
			left join [PRIORITY] p
			on wit.PRIORITYID = p.PRIORITYID
			join WTS_RESOURCE ar
			on wit.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
			join ORGANIZATION ao
			on ar.ORGANIZATIONID = ao.ORGANIZATIONID
			left join w_SubTaskAOR_WorkType tawt
			on wiT.WORKITEM_TASKID = tawt.WORKITEM_TASKID
			and tawt.AORWorkTypeID in (1,-1) --Workload MGMT
			left join w_SubTaskAOR_WorkType tawt2
			on wiT.WORKITEM_TASKID = tawt2.WORKITEM_TASKID
			and tawt2.AORWorkTypeID = 2 --Release/Deployment MGMT
			left join AORReleaseTask rta
			on tawt.AORReleaseID = rta.AORReleaseID
			and wit.WORKITEMID = rta.WORKITEMID
		),
		w_filtered_tasks as (
			select wi.*, s.[STATUS],s.[SORT_ORDER] as StatusStage, p.[PRIORITY], ao.ORGANIZATION,
			tawt.AORID,
			tawt.AORName,
			tawt.AORReleaseID,
			convert(int, tawt.CascadeAOR) as CascadeAOR,
			tawt. AORType,
			tawt.InvestigationStage,
			tawt.TechnicalStage,
			tawt.CustomerDesignStage,
			tawt.CodingStage,
			tawt.InternalTestingStage,
			tawt.CustomerValidationTestingStage,
			tawt.AdoptionStage,
			tawt2.AORID as AORID2,
			tawt2.AORName as AORName2,
			tawt2.AORReleaseID as AORReleaseID2,
			convert(int, tawt2.CascadeAOR) as CascadeAOR2,
			tawt2.AORType as AORType2,
			tawt2.InvestigationStage as InvestigationStage2,
			tawt2.TechnicalStage as TechnicalStage2,
			tawt2.CustomerDesignStage as CustomerDesignStage2,
			tawt2.CodingStage as CodingStage2,
			tawt2.InternalTestingStage as InternalTestingStage2,
			tawt2.CustomerValidationTestingStage as CustomerValidationTestingStage2,
			tawt2.AdoptionStage as AdoptionStage2
			from WORKITEM wi
			join [STATUS] s
			on wi.STATUSID = s.STATUSID
			join [PRIORITY] p
			on wi.PRIORITYID = p.PRIORITYID
			join WTS_RESOURCE ar
			on wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
			join ORGANIZATION ao
			on ar.ORGANIZATIONID = ao.ORGANIZATIONID
			left join w_TaskAOR_WorkType tawt
			on wi.WORKITEMID = tawt.WORKITEMID
			and tawt.AORWorkTypeID in (1,-1) --Workload MGMT
			left join w_TaskAOR_WorkType tawt2
			on wi.WORKITEMID = tawt2.WORKITEMID
			and tawt2.AORWorkTypeID = 2 --Release/Deployment MGMT
		)

	select AOR.AORID as AOR_ID,
		AOR.AORName as [AOR Name],
		rta.AORReleaseTaskID as AORReleaseTask_ID,
		wi.WORKITEMID as Task_ID,
		wi.WORKITEMID as [Task #],
		wi.TITLE as [Title],
		ws.WTS_SYSTEMID as WTS_SYSTEM_ID,
		ws.WTS_SYSTEM as [System(Task)],
		pv.ProductVersionID as ProductVersion_ID,
		pv.ProductVersion as [Product Version],
		ps.STATUSID as ProductionStatus_ID,
		ps.[STATUS] as [Production Status],
		p.PRIORITYID as PRIORITY_ID,
		p.[PRIORITY] as [Priority],
		wi.SR_Number as [SR Number],
		ato.WTS_RESOURCEID as AssignedTo_ID,
		ato.USERNAME as [Assigned To],
		ptr.WTS_RESOURCEID as PrimaryTechResource_ID,
		ptr.USERNAME as [Primary Resource],
		s.STATUSID as STATUS_ID,
		s.[STATUS] as [Status],
		wi.COMPLETIONPERCENT as [Percent Complete]
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	join AORReleaseTask rta
	on arl.AORReleaseID = rta.AORReleaseID
	join WORKITEM wi
	on rta.WORKITEMID = wi.WORKITEMID
	left join WORKITEM_TASK wit
	on wi.WORKITEMID = wit.WORKITEMID
	join WTS_SYSTEM ws
	on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
	left join ProductVersion pv
	on wi.ProductVersionID = pv.ProductVersionID
	left join [STATUS] ps
	on wi.ProductionStatusID = ps.STATUSID
	join [PRIORITY] p
	on wi.PRIORITYID = p.PRIORITYID
	join WTS_RESOURCE ato
	on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
	left join WTS_RESOURCE ptr
	on wi.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
	left join WTS_RESOURCE str
	on wi.SECONDARYRESOURCEID = str.WTS_RESOURCEID
	left join WTS_RESOURCE pbr
	on wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID
	left join WTS_RESOURCE sbr
	on wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID
	join [STATUS] s
	on wi.STATUSID = s.STATUSID
	where (@AORID = 0 or AOR.AORID = @AORID)
	and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
	order by upper(AOR.AORName), wi.WORKITEMID desc;
end;

GO

