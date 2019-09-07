USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[SRList_Get]    Script Date: 9/13/2018 5:00:53 PM ******/
DROP PROCEDURE [dbo].[SRList_Get]
GO

/****** Object:  StoredProcedure [dbo].[SRList_Get]    Script Date: 9/13/2018 5:00:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[SRList_Get]
	@SRID int = 0,
	@SubmittedBy nvarchar(max) = '',
	@StatusIDs nvarchar(max) = '',
	@SRTypeIDs nvarchar(max) = '',
	@Systems nvarchar(max) = '',
	@SRIDs nvarchar(max) = '',
	@AORSRIDs nvarchar(max) = ''
as
begin

-- if the user specifies an srid, srids, or aorsrids, then we clear out the ddl filters so we can match on those numbers no matter what
if ISNULL(@SRID, 0) > 0 or ISNULL(@SRIDs, '') <> '' or ISNULL(@AORSRIDs, '') <> ''
begin
	set @SubmittedBy = ''
	set @StatusIDs = ''
	set @SRTypeIDs = ''
	set @Systems = ''
end

select * from
	(
		select distinct SR.SRID as SR_ID,
			SR.SRID as [SR #],
			CASE SR.Closed 
				WHEN 1 THEN 44
				ELSE SR.SRRankID 
			END as SRRankID,
			wre.USERNAME as [Submitted By],
			SR.CreatedDate as [Submitted Date],
			CASE SR.Closed 
				WHEN 1 THEN 125
				ELSE s.STATUSID
			END as StatusID,
			srt.SRTypeID as [Type_ID],
			srt.SRType as Reasoning,
			p.PRIORITYID as Priority_ID,
			p.[PRIORITY] as [User's Priority],
			SR.INVPriorityID as INVPriorityID,
			CASE SR.INVPriorityID 
				WHEN 0 THEN ''
				WHEN 32 THEN 'Low'
				WHEN 33 THEN 'Medium'
				WHEN 34 THEN 'High'
			END as INVPriority,
			'WTS' AS System,
			SR.[Description],
			CASE 
				WHEN wit.workitemid > 0 THEN CAST(wit.WORKITEMID as nvarchar(10)) + '-' + CAST(wit.WORKITEM_TASKID as nvarchar(10)) + '-' + CAST(wit.TASK_NUMBER as nvarchar(10))
				WHEN wi.WORKITEMID is not null THEN CAST(wi.WORKITEMID as nvarchar(10))
			END as TaskData,
			CASE SR.Closed 
				WHEN 1 THEN 99
				ELSE SR.Sort
			END as Sort,
			lower(SR.CreatedBy) as CreatedBy_ID,
			SR.CreatedDate as CreatedDate_ID,
			lower(SR.UpdatedBy) as UpdatedBy_ID,
			SR.UpdatedDate as UpdatedDate_ID,
			'' as Z
		from SR
		join WTS_RESOURCE wre
		on SR.SubmittedByID = wre.WTS_RESOURCEID
		join [STATUS] s
		on SR.STATUSID = s.STATUSID
		join SRType srt
		on SR.SRTypeID = srt.SRTypeID
		join [PRIORITY] p
		on SR.PRIORITYID = p.PRIORITYID
		left join WORKITEM wi
		on SR.SRID = wi.SR_Number
		left join WORKITEM_TASK wit
		on SR.SRID = wit.SRNumber
		where SR.Archive = 0
		and (isnull(@SRID, 0) = 0 or SR.SRID = @SRID)
		and (isnull(@SRIDs, '') = '' or CHARINDEX(',' + CONVERT(VARCHAR(100), SR.SRID) + ',', ',' + @SRIDs + ',', 1) > 0)
		and (isnull(@SubmittedBy, '') = '' or wre.USERNAME IN (SELECT * FROM Split(@SubmittedBy, ',')))
		and (isnull(@StatusIDs, '') = '' or (
			(s.STATUSID IN (SELECT * FROM Split(@StatusIDs, ',')) and sr.Closed = 0)
			or sr.Closed in (SELECT case Data when 125 then 1 else -1 end FROM Split(@StatusIDs, ',')))
		)
		and (isnull(@SRTypeIDs, '') = '' or srt.SRTypeID IN (SELECT * FROM Split(@SRTypeIDs, ',')))
		and (isnull(@Systems, '') = '' or 'WTS' IN (SELECT * FROM Split(@Systems, ',')))

		UNION ALL

		select distinct AORSR.SRID as SR_ID,
			AORSR.SRID as [SR #],
			0 as SRRankID,
			AORSR.SubmittedBy as [Submitted By],
			AORSR.SubmittedDate as [Submitted Date],
			s.STATUSID as StatusID,
			srt.SRTypeID as [Type_ID],
			srt.SRType as Reasoning,
			p.PRIORITYID as Priority_ID,
			p.[PRIORITY] as [User's Priority],
			32 as INVPriorityID,
			'Low' as INVPriority,
			AORSR.Websystem as System,
			AORSR.[Description],
			CASE 
				WHEN wit.workitemid > 0 THEN CAST(wit.WORKITEMID as nvarchar(10)) + '-' + CAST(wit.WORKITEM_TASKID as nvarchar(10)) + '-' + CAST(wit.TASK_NUMBER as nvarchar(10))
				WHEN wi.WORKITEMID is not null THEN CAST(wi.WORKITEMID as nvarchar(10))
			END as TaskData,
			AORSR.Sort,
			lower(AORSR.CreatedBy) as CreatedBy_ID,
			AORSR.CreatedDate as CreatedDate_ID,
			lower(AORSR.UpdatedBy) as UpdatedBy_ID,
			AORSR.UpdatedDate as UpdatedDate_ID,
			'' as Z
		from AORSR
		left join WTS_RESOURCE wre
		on AORSR.CreatedBy = wre.USERNAME
		join [STATUS] s
		on AORSR.[STATUS] = s.[STATUS]
		join SRType srt
		on AORSR.SRType = srt.SRType
		join [PRIORITY] p
		on AORSR.[PRIORITY] = p.[PRIORITY]
		left join WORKITEM wi
		on AORSR.SRID = wi.SR_Number
		left join WORKITEM_TASK wit
		on AORSR.SRID = wit.SRNumber
		where AORSR.Archive = 0
		and (AORSR.Websystem LIKE '%CAFDEx/WSS%' or AORSR.Websystem LIKE '%CAFDEx/FHP%')
		and s.StatusTypeID = 16
		and p.PRIORITYTYPEID = 6
		and (isnull(@SRID, 0) = 0 or AORSR.SRID = @SRID)
		and (isnull(@AORSRIDs, '') = '' or CHARINDEX(',' + CONVERT(VARCHAR(100), AORSR.SRID) + ',', ',' + @AORSRIDs + ',', 1) > 0)
		and (isnull(@SubmittedBy, '') = '' or AORSR.SubmittedBy IN (SELECT * FROM Split(@SubmittedBy, ',')))
		and (isnull(@StatusIDs, '') = '' or s.STATUSID IN (SELECT * FROM Split(@StatusIDs, ',')))
		and (isnull(@SRTypeIDs, '') = '' or srt.SRTypeID IN (SELECT * FROM Split(@SRTypeIDs, ',')))
		and (isnull(@Systems, '') = '' or AORSR.Websystem IN (SELECT * FROM Split(@Systems, ',')))
	) a
	order by 
		case a.SRRankID when 0 then 1 else 0 end, a.SRRankID, 
		case a.Sort when 0 then 1 else 0 end, a.Sort, 
		a.SR_ID;
end;
GO


