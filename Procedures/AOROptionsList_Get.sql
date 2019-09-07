USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AOROptionsList_Get]    Script Date: 12/4/2017 11:52:22 AM ******/
DROP PROCEDURE [dbo].[AOROptionsList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AOROptionsList_Get]    Script Date: 12/4/2017 11:52:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AOROptionsList_Get]
	@AORID int = 0,
	@TaskID int = 0,
	@AORMeetingID int = 0,
	@AORMeetingInstanceID int = 0
as
begin
	declare @date datetime;

	set @date = getdate();

	--CR Status
	select *
	from (
		select distinct isnull(s.STATUSID, 0) as Value,
			s.[STATUS] as [Text]
		from AORCR acr
		left join [STATUS] s
		on acr.StatusID = s.STATUSID
		where not exists (
			select 1
			from AORReleaseCR arc
			join AORRelease arl
			on arc.AORReleaseID = arl.AORReleaseID
			where arc.CRID = acr.CRID
			and arl.AORID = @AORID
			and arl.[Current] = 1
		)
	) a
	order by upper(a.[Text]);

	--CR Contract
	select *
	from (
		select distinct isnull(c.CONTRACTID, 0) as Value,
			c.[CONTRACT] as [Text]
		from AORCR acr
		left join [CONTRACT] c
		on acr.ContractID = c.CONTRACTID
		where not exists (
			select 1
			from AORReleaseCR arc
			join AORRelease arl
			on arc.AORReleaseID = arl.AORReleaseID
			where arc.CRID = acr.CRID
			and arl.AORID = @AORID
			and arl.[Current] = 1
		)
	) a
	order by upper(a.[Text]);

	--Release
	select isnull(a.ProductVersionID, -999) as Value,
		a.ProductVersion as [Text]
	from (
		select pv.ProductVersionID,
			pv.ProductVersion
		from AORRelease arl
		left join ProductVersion pv
		on arl.SourceProductVersionID = pv.ProductVersionID
		where arl.AORID = @AORID
		union
		select pv.ProductVersionID,
			pv.ProductVersion
		from AORRelease arl
		left join ProductVersion pv
		on arl.ProductVersionID = pv.ProductVersionID
		where arl.AORID = @AORID
	) a
	order by upper(a.ProductVersion);

	--Field Changed
	with aor_release as (
		select arl.AORReleaseID,
			arl.CreatedDate,
			(select CreatedDate from AORRelease where AORReleaseID = (select min(AORReleaseID) from AORRelease where AORID = arl.AORID and AORReleaseID > arl.AORReleaseID)) as EndDate
		from AORRelease arl
		where (@AORID = 0 or arl.AORID = @AORID)
	)
	select a.FieldChanged as Value,
		a.FieldChanged as [Text]
	from (
		select wih.FieldChanged
		from aor_release arl
		join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		join WorkItem_History wih
		on art.WORKITEMID = wih.WORKITEMID
		where wih.CREATEDDATE between arl.CreatedDate and isnull(arl.EndDate, @date)
		and wih.WORKITEMID = @TaskID
		union
		select wth.FieldChanged
		from aor_release arl
		join AORReleaseTask art
		on arl.AORReleaseID = art.AORReleaseID
		join WORKITEM_TASK wit
		on art.WORKITEMID = wit.WORKITEMID
		join WORKITEM_TASK_HISTORY wth
		on wit.WORKITEM_TASKID = wth.WORKITEM_TASKID
		where wth.CREATEDDATE between arl.CreatedDate and isnull(arl.EndDate, @date)
		and wit.WORKITEMID = @TaskID
	) a
	order by upper(a.FieldChanged);

	--Note Type
	select a.AORNoteTypeID as Value,
		a.AORNoteTypeName as [Text]
	from (
		select distinct ant.AORNoteTypeID,
			ant.AORNoteTypeName
		from AORMeetingNotes amn
		join AORNoteType ant
		on amn.AORNoteTypeID = ant.AORNoteTypeID
		where amn.AORMeetingID = @AORMeetingID
		and (amn.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amn.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
	) a
	order by a.AORNoteTypeName;

	--SR Status
	select *
	from (
		select distinct isnull(asr.[STATUS], 0) as Value,
			asr.[STATUS] as [Text]
		from AORSR asr
	) a
	order by upper(a.[Text]);

	--System Task Contract
	select *
	from (
		select distinct isnull(c.[CONTRACTID], 0) as Value,
		c.[CONTRACT] as [Text]
		from AORRelease arl
		left join [AORReleaseTask] art
		on arl.AORReleaseID = art.AORReleaseID
		left join [WORKITEM] wi
		on art.[WORKITEMID] = wi.[WORKITEMID]
		left join [WTS_SYSTEM_CONTRACT] wsc
		on wi.[WTS_SYSTEMID] = wsc.[WTS_SYSTEMID]
		left join [CONTRACT] c
		on wsc.[CONTRACTID] = c.[CONTRACTID]
	) a
	order by upper(a.[Text]);

	--CR Related Release
	select *
	from (
		select distinct rtrim(ltrim(isnull(Data, -1))) AS Value,
			rtrim(ltrim(Data)) AS [Text]
		from AORCR acr
		left join AORReleaseCR arc
		on acr.CRID = arc.CRID
		CROSS APPLY SPLIT(acr.[RelatedRelease], ',')
	) a
	order by upper(a.[Text]);

	--AOR Production Status
	select *
	from (
		select distinct isnull(rps.WorkloadAllocationID, 0) AS Value,
			rps.WorkloadAllocation AS [Text]
		from AOR 
		left join AORRelease arl 
		on AOR.AORID = arl.AORID
		left join WorkloadAllocation rps 
		on arl.WorkloadAllocationID = rps.WorkloadAllocationID
	) a
	order by upper(a.[Text]);
	

end;


GO

