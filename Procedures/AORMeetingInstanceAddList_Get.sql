USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAddList_Get]    Script Date: 3/7/2018 2:04:24 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceAddList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceAddList_Get]    Script Date: 3/7/2018 2:04:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORMeetingInstanceAddList_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@Type nvarchar(50),
	@QFSystem nvarchar(255) = '',
	@QFRelease nvarchar(255) = '',
	@QFName nvarchar(255) = '',
	@InstanceFilterID int = 0,
	@NoteTypeFilterID int = 0
as
begin
	if @Type = 'AOR'
		begin
			select '' as X,
				AOR.AORID as [AOR #],
				arl.AORName as [AOR Name],
				arl.AORReleaseID as AORRelease_ID,
				wsy.WTS_SYSTEMID as WTS_SYSTEM_ID,
				wsy.WTS_SYSTEM as [System]
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			left join AORReleaseSystem ars
			on arl.AORReleaseID = ars.AORReleaseID
			left join WTS_SYSTEM wsy
			on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			where AOR.Archive = 0
			and arl.[Current] = 1
			and not exists (
				select 1
				from AORMeetingAOR ama
				join AORRelease rel
				on ama.AORReleaseID = rel.AORReleaseID
				where ama.AORMeetingID = @AORMeetingID
				and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
				and ama.AORMeetingInstanceID_Remove is null
				and rel.AORID = AOR.AORID
			)
			and (isnull(@QFSystem, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsy.WTS_SYSTEMID, 0)) + ',', ',' + @QFSystem + ',') > 0)
			and (isnull(@QFRelease, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @QFRelease + ',') > 0)
			and (isnull(@QFName, '') = '' or charindex(@QFName, arl.AORName) > 0)
			order by upper(wsy.WTS_SYSTEM), upper(arl.AORName);
		end;
	else if @Type = 'Resource'
		begin
			select '' as X,
				wre.WTS_RESOURCEID as WTS_RESOURCE_ID,
				wre.USERNAME as [Resource]
			from WTS_RESOURCE wre
			where wre.ARCHIVE = 0
			and wre.AORResourceTeam = 0
			and not exists (
				select 1
				from AORMeetingResource amr
				where amr.AORMeetingID = @AORMeetingID
				and amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID
				and amr.AORMeetingInstanceID_Remove is null
				and wre.WTS_RESOURCEID = amr.WTS_RESOURCEID
			)
			order by upper(wre.USERNAME);
		end;
	else if @Type = 'Note Type'
		begin
			select ant.AORNoteTypeID,
				ant.AORNoteTypeName
			from AORNoteType ant
			where not exists (
				select 1
				from AORMeetingNotes amn
				where amn.AORMeetingID = @AORMeetingID
				and amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID
				and amn.AORMeetingNotesID_Parent is null
				and amn.AORMeetingInstanceID_Remove is null
				and ant.AORNoteTypeID = amn.AORNoteTypeID
			)
			order by ant.Sort;
		end;
	else if @Type in ('Note Detail', 'Edit Note Detail', 'View Note Detail')
		begin
			select AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				isnull(ps.WorkloadAllocation, '') as WorkloadAllocation
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORMeetingAOR ama
			on arl.AORReleaseID = ama.AORReleaseID
			left join WorkloadAllocation ps
			on arl.WorkloadAllocationID = ps.WorkloadAllocationID
			where AOR.Archive = 0
			and ama.AORMeetingID = @AORMeetingID
			and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
			and ama.AORMeetingInstanceID_Remove is null
			order by case upper(ps.WorkloadAllocation) when 'RELEASE CAFDEX' then 0 when 'PRODUCTION SUPPORT' then 1 else 2 end, upper(arl.AORName);
		end;
	else if @Type in ('Note Detail All System AOR')
		begin
			select AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				wsy.WTS_SYSTEMID,
				isnull(wsy.WTS_SYSTEM, 'No System') as WTS_SYSTEM,
				isnull(ps.WorkloadAllocation, '') as WorkloadAllocation
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			left join AORReleaseSystem ars
			on arl.AORReleaseID = ars.AORReleaseID
			left join WTS_SYSTEM wsy
			on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			left join WorkloadAllocation ps
			on arl.WorkloadAllocationID = ps.WorkloadAllocationID
			where AOR.Archive = 0
			and arl.[Current] = 1
			order by case when wsy.WTS_SYSTEM is null then 1 else 0 end, upper(wsy.WTS_SYSTEM), case upper(ps.WorkloadAllocation) when 'RELEASE CAFDEX' then 0 when 'PRODUCTION SUPPORT' then 1 else 2 end, upper(arl.AORName);
		end;
	else if @Type in ('Note Detail All AOR')
		begin
			select AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				isnull(ps.WorkloadAllocation, '') as WorkloadAllocation
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			left join WorkloadAllocation ps
			on arl.WorkloadAllocationID = ps.WorkloadAllocationID
			where AOR.Archive = 0
			and arl.[Current] = 1
			order by case upper(ps.WorkloadAllocation) when 'RELEASE CAFDEX' then 0 when 'PRODUCTION SUPPORT' then 1 else 2 end, upper(arl.AORName);
		end;
	else if @Type = 'Historical Notes'
		begin
			select ami.InstanceDate as [Instance Date],
				ant.AORNoteTypeName as [Note Type],
				amn.AORMeetingNotesID as [Note #],
				amn.Title,
				--amn.Notes as [Note Details],
				arl.AORName as [AOR Name],
				s.[STATUS] as [Status]
			from AORMeetingNotes amn
			join [STATUS] s
			on amn.STATUSID = s.STATUSID
			left join AORRelease arl
			on amn.AORReleaseID = arl.AORReleaseID
			left join AOR
			on arl.AORID = AOR.AORID
			join AORNoteType ant
			on amn.AORNoteTypeID = ant.AORNoteTypeID
			join AORMeetingInstance ami
			on amn.AORMeetingInstanceID_Add = ami.AORMeetingInstanceID
			where amn.AORMeetingID = @AORMeetingID
			and amn.AORMeetingNotesID_Parent is not null
			and amn.AORMeetingInstanceID_Remove is null
			and ami.InstanceDate < (select InstanceDate from AORMeetingInstance where AORMeetingInstanceID = @AORMeetingInstanceID)
			and (@InstanceFilterID = 0 or ami.AORMeetingInstanceID = @InstanceFilterID)
			and (@NoteTypeFilterID = 0 or amn.AORNoteTypeID = @NoteTypeFilterID)
			and AOR.Archive = 0
			order by ami.InstanceDate desc, ant.Sort, amn.Sort, amn.AORMeetingNotesID desc
		end;
end;
GO


