USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[QM_Workload_Crosswalk_Multi_Level_Grid]    Script Date: 6/19/2018 10:20:31 AM ******/
DROP PROCEDURE [dbo].[QM_Workload_Crosswalk_Multi_Level_Grid]
GO

/****** Object:  StoredProcedure [dbo].[QM_Workload_Crosswalk_Multi_Level_Grid]    Script Date: 6/19/2018 10:20:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











CREATE procedure [dbo].[QM_Workload_Crosswalk_Multi_Level_Grid]
	@SessionID nvarchar(100),
	@UserName nvarchar(100),
	@Level xml,
	@Filter xml,
	@QFStatus nvarchar(max),
	@QFAffiliated nvarchar(max),
	@QFBusinessReview nvarchar(10) = '0',
	@OwnedBy nvarchar(10) = '0',
	@Debug bit = 0
as
begin
	set nocount on;

	declare @sql nvarchar(max) = '';
	declare @sql_with nvarchar(max) = '';
	declare @sql_select nvarchar(max) = '';
	declare @sql_select_sub nvarchar(max) = '';
	declare @sql_from nvarchar(max) = '';
	declare @sql_from_sub nvarchar(max) = '';
	declare @sql_where nvarchar(max) = '';
	declare @sql_where_sub nvarchar(max) = '';
	declare @sql_where_sub_Parent nvarchar(max) = '';
	declare @sql_where_exclude nvarchar(max) = '';
	declare @sql_group nvarchar(max) = '';
	declare @sql_group_sub nvarchar(max) = '';
	declare @sql_order_by_Aff nvarchar(max) = '';
	declare @sql_order_by nvarchar(max) = '';
	declare @sql_select_level nvarchar(max) = '';
	declare @sql_from_level nvarchar(max) = '';
	declare @sql_from_level_RC nvarchar(max) = '';
	declare @sql_from_level_RQMTRisk nvarchar(max) = '';
	declare @sql_rollups nvarchar(max) = '';
	declare @sql_rollups_sub nvarchar(max) = '';
	declare @sql_rollups_level nvarchar(max) = '';
	declare @sql_rollups_level_W_Assigned nvarchar(max) = '';
	declare @sql_from_level_W_Assigned nvarchar(max) = '';


	with
	w_breakout as (
		select
			tbl.breakouts.value('column[1]', 'varchar(100)') as columnName,
			tbl.breakouts.value('sort[1]', 'varchar(100)') as columnSort
		from @Level.nodes('crosswalkparameters/level/breakout') as tbl(breakouts)
	),
	/*w_rollup as (
		select
			tbl.rollups.value('field[1]', 'varchar(100)') as fieldName,
			tbl.rollups.value('type[1]', 'varchar(100)') as typeName
		from @Level.nodes('crosswalkparameters/level/rollup') as tbl(rollups)
	),*/
	w_filter as (
		select
			tbl.filters.value('field[1]', 'varchar(100)') as fieldName,
			tbl.filters.value('id[1]', 'varchar(100)') as fieldID
		from @Filter.nodes('/filters/filter') as tbl(filters)
	)
	select @sql_select = stuff((select ', ' + [dbo].[Get_Columns](columnName, 0, '', 0, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_select_sub = stuff((select ', ' + [dbo].[Get_Columns](columnName, 0, '', 1, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_from = stuff((select distinct tableName from (select ' ' + [dbo].[Get_Tables](columnName, 0, 0) as tableName from w_breakout union select ' ' + [dbo].[Get_Tables](fieldName, 0, 0) as tableName from w_filter) allTables for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_from_sub = stuff((select distinct tableName from (select ' ' + [dbo].[Get_Tables](columnName, 0, 1) as tableName from w_breakout union select ' ' + [dbo].[Get_Tables](fieldName, 0, 1) as tableName from w_filter) allTables for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_where = stuff((select distinct ' ' + [dbo].[Get_Columns](fieldName, 1, fieldID, 0, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_where_sub = stuff((select distinct ' ' + [dbo].[Get_Columns](fieldName, 1, fieldID, 1, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_where_sub_Parent = stuff((select distinct ' ' + [dbo].[Get_Columns](fieldName, 6, fieldID, 1, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_where_exclude = stuff((select distinct ' ' + [dbo].[Get_Tables](columnName, 2, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_group = stuff((select ', ' + [dbo].[Get_Columns](columnName, 2, '', 0, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_group_sub = stuff((select ', ' + [dbo].[Get_Columns](columnName, 2, '', 1, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_order_by_Aff = isnull(stuff((select ', ' + [dbo].[Get_Columns](columnName, 5, fieldID, 0, columnSort) from w_breakout, w_filter where fieldName = 'Affiliated_ID' for xml path('') , type).value('.', 'nvarchar(max)'), 1, 1, ''),''),
		   @sql_order_by = stuff((select ', ' + [dbo].[Get_Columns](columnName, 3, '', 0, columnSort) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_select_level = stuff((select ', ' + [dbo].[Get_Columns](columnName, 4, '', 0, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_from_level = stuff((select distinct ' ' + [dbo].[Get_Tables](columnName, 1, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_from_level_RC = stuff((select distinct ' ' + [dbo].[Get_Tables](columnName, 3, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_from_level_RQMTRisk = stuff((select distinct ' ' + [dbo].[Get_Tables](columnName, 4, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');/*,
		   @sql_rollups = stuff((select ', ' + [dbo].[Get_Rollups](fieldName, typeName, 0) from w_rollup for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_rollups_sub = stuff((select ', ' + [dbo].[Get_Rollups](fieldName, typeName, 1) from w_rollup for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_rollups_level = stuff((select ', ' + [dbo].[Get_Rollups](fieldName, typeName, 2) from w_rollup for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');*/

	--temp
	set @sql_rollups = [dbo].[Get_Rollups]('Status', 'Count of tasks', 0);
	set @sql_rollups_sub = [dbo].[Get_Rollups]('Status', 'Count of tasks', 1);
	set @sql_rollups_level = [dbo].[Get_Rollups]('Status', 'Count of tasks', 2);
	set @sql_rollups_level_W_Assigned = [dbo].[Get_Rollups]('Status', 'Count of tasks', 3);
	--

	--Start Alter parameters
	if (charindex('TASK_NUMBER', upper(@sql_select_level)) > 0 and charindex('WI.WORKITEMID', upper(@sql_where_sub)) > 0)
			begin
				set @sql_where_sub = @sql_where_sub_Parent;
			end;

	if @sql_select = ''
		begin
			select 'No Data Found' as 'QM Workload Crosswalk';
			return;
		end;

	if right(@sql_where, 4) = 'and '
		begin
			set @sql_where = left(@sql_where, len(@sql_where) - 4)
		end;

	if right(@sql_where_sub, 4) = 'and '
		begin
			set @sql_where_sub = left(@sql_where_sub, len(@sql_where_sub) - 4)
		end;

	if right(@sql_where_exclude, 4) = 'and '
		begin
			set @sql_where_exclude = left(@sql_where_exclude, len(@sql_where_exclude) - 4)
		end;

	if right(@sql_from_level, 4) = 'and '
		begin
			set @sql_from_level = left(@sql_from_level, len(@sql_from_level) - 4)
		end;

	if charindex('RESOURCE COUNT (T.BA.PA.CT)', upper(@sql_select_level)) > 0
		begin
			if right(@sql_from_level_RC, 4) = 'and '
				begin
					set @sql_from_level_RC = ' left join w_RC_TOTALS rct on ' + left(@sql_from_level_RC, len(@sql_from_level_RC) - 4)
				end;
		end;
	else
		begin
			set @sql_from_level_RC = '';
		end;
	if charindex('RQMT RISK', upper(@sql_select_level)) > 0
		begin
			if charindex('PRIMARY TASK', upper(@sql_select_level)) > 0 or charindex('WORK TASK', upper(@sql_select_level)) > 0
				begin
					set @sql_from_level_RQMTRisk = ' left join w_RQMT_Risk rr on isnull(trs.WORKITEMID, tr.WORKITEMID) = rr.WORKITEMID';
				end;
			else if right(@sql_from_level_RQMTRisk, 4) = 'and '
				begin
					set @sql_from_level_RQMTRisk = ' left join w_RQMT_Risk rr on ' + left(@sql_from_level_RQMTRisk, len(@sql_from_level_RQMTRisk) - 4)
				end;
		end;
	else
		begin
			set @sql_from_level_RQMTRisk = '';
		end;
	if (charindex('WORKITEMID', upper(@sql_select)) > 0 and charindex('AOR_WORKLOAD_MGMT_ID', upper(@sql_select)) > 0)
		begin
			set @sql_select = @sql_select + ' ,isnull(wi.CascadeAOR,0) as CascadeAOR_WORKLOAD_MGMT_ID ';
			set @sql_select_sub = @sql_select_sub + ' , isnull(wit.CascadeAOR,0) as CascadeAOR_WORKLOAD_MGMT_ID ';
			set @sql_group = @sql_group +  ' , isnull(wi.CascadeAOR,0) ';
			set @sql_group_sub = @sql_group_sub +  ' , isnull(wit.CascadeAOR,0) ';
			set @sql_select_level = @sql_select_level +  ' , isnull(trs.CascadeAOR_WORKLOAD_MGMT_ID, tr.CascadeAOR_WORKLOAD_MGMT_ID) as CascadeAOR_WORKLOAD_MGMT_ID';
		end;

	if (charindex('WORKITEMID', upper(@sql_select)) > 0 and charindex('AOR_RELEASE_MGMT_ID', upper(@sql_select)) > 0)
		begin
			set @sql_select = @sql_select + ' ,isnull(wi.CascadeAOR2,0) as CascadeAOR_RELEASE_MGMT_ID ';
			set @sql_select_sub = @sql_select_sub + ' , isnull(wit.CascadeAOR2,0) as CascadeAOR_RELEASE_MGMT_ID ';
			set @sql_group = @sql_group +  ' , isnull(wi.CascadeAOR2,0) ';
			set @sql_group_sub = @sql_group_sub +  ' , isnull(wit.CascadeAOR2,0) ';
			set @sql_select_level = @sql_select_level +  ' , isnull(trs.CascadeAOR_RELEASE_MGMT_ID, tr.CascadeAOR_RELEASE_MGMT_ID) as CascadeAOR_RELEASE_MGMT_ID';
		end;

	if (charindex('WORKITEM_TASKID', upper(@sql_select)) > 0 and charindex('AOR_WORKLOAD_MGMT_ID', upper(@sql_select)) > 0)
		begin
			set @sql_select_sub = @sql_select_sub + ' , wi.WTS_SYSTEMID  ';
			set @sql_group = @sql_group +  ' , wi.WTS_SYSTEMID ';
			set @sql_group_sub = @sql_group_sub +  ' , wi.WTS_SYSTEMID ';
			set @sql_select_level = @sql_select_level +  ' , isnull(trs.WTS_SYSTEMID, tr.WTS_SYSTEMID) as SystemTask_ID';
		end;

	if (charindex('WORKITEMID', upper(@sql_select)) > 0 and charindex('WTS_SYSTEMID', upper(@sql_select)) = 0)
		begin
			set @sql_select = @sql_select + ' , wi.WTS_SYSTEMID  ';
			set @sql_select_sub = @sql_select_sub + ' , wi.WTS_SYSTEMID  ';
			set @sql_group = @sql_group +  ' , wi.WTS_SYSTEMID ';
			set @sql_group_sub = @sql_group_sub +  ' , wi.WTS_SYSTEMID ';
			set @sql_select_level = @sql_select_level +  ' , isnull(trs.WTS_SYSTEMID, tr.WTS_SYSTEMID) as SystemTask_ID';
		end;

	if (charindex('WORKITEMID', upper(@sql_select)) > 0 and charindex('PRODUCTIONSTATUS_ID', upper(@sql_select)) = 0)
		begin
			set @sql_select = @sql_select + ' , wi.ProductionStatusID  ';
			set @sql_select_sub = @sql_select_sub + ' , wi.ProductionStatusID  ';
			set @sql_group = @sql_group +  ' , wi.ProductionStatusID ';
			set @sql_group_sub = @sql_group_sub +  ' , wi.ProductionStatusID ';
			set @sql_select_level = @sql_select_level +  ' , isnull(trs.ProductionStatusID, tr.ProductionStatusID) as PRODUCTIONSTATUS_ID';
		end;

	if (charindex('WORKITEMID', upper(@sql_select)) > 0 and charindex('ASSIGNEDTO_ID', upper(@sql_select)) = 0)
		begin
			set @sql_select = @sql_select + ' , wi.ASSIGNEDRESOURCEID  ';
			set @sql_select_sub = @sql_select_sub + ' , wit.ASSIGNEDRESOURCEID  ';
			set @sql_group = @sql_group +  ' , wi.ASSIGNEDRESOURCEID ';
			set @sql_group_sub = @sql_group_sub +  ' , wit.ASSIGNEDRESOURCEID ';
			set @sql_select_level = @sql_select_level +  ' , isnull(trs.ASSIGNEDRESOURCEID, tr.ASSIGNEDRESOURCEID) as ASSIGNEDTO_ID';
		end;

	if (charindex('WORKITEMID', upper(@sql_select)) > 0 and charindex('PRIMARYTECHRESOURCE_ID', upper(@sql_select)) = 0)
		begin
			set @sql_select = @sql_select + ' , wi.PrimaryResourceID  ';
			set @sql_select_sub = @sql_select_sub + ' , wit.PrimaryResourceID  ';
			set @sql_group = @sql_group +  ' , wi.PrimaryResourceID ';
			set @sql_group_sub = @sql_group_sub +  ' , wit.PrimaryResourceID ';
			set @sql_select_level = @sql_select_level +  ' , isnull(trs.PrimaryResourceID, tr.PrimaryResourceID) as PRIMARYTECHRESOURCE_ID';
		end;
	--End Alter parameters

	--Start Add Temp Tables to Dynamic SQL
	set @sql = @sql + 'USE WTS;
	select distinct TeamResourceID, ResourceID
	into #AffiliatedResourceTeamUser
	from AORReleaseResourceTeam rrt
	join AORRelease arl
	on rrt.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and charindex('','' + convert(nvarchar(10), rrt.ResourceID) + '','', '',' + @QFAffiliated + ','') > 0;

	create nonclustered index idx_AffiliatedResourceTeamUser ON #AffiliatedResourceTeamUser (TeamResourceID, ResourceID);
	create nonclustered index idx_AffiliatedResourceTeamUser2 ON #AffiliatedResourceTeamUser (ResourceID, TeamResourceID);
	';

	if (charindex('RQMT RISK', upper(@sql_select_level)) > 0)
		begin
			set @sql = @sql + '
			select was.WTS_SYSTEMID,
				was.WorkAreaID,
				rs.RQMTSystemID,
				case when (select count(1)
				from RQMTSystemDefect rsd
				where rsd.RQMTSystemID = rs.RQMTSystemID
				and rsd.Resolved = 0
				and rsd.ImpactID = 7) > 0 then rs.RQMTSystemID else null end as WorkStoppage,
				case when (select count(1)
				from RQMTSystemDefect rsd
				where rsd.RQMTSystemID = rs.RQMTSystemID
				and rsd.Resolved = 0) > 0 then rs.RQMTSystemID else null end as Deficient,
				case when rs.CriticalityID = 2 or rs.RQMTStatusID = 15 then rs.RQMTSystemID else null end as DNTNotTested
			into #RQMTData
			from RQMT r
			left join RQMTSystem rs
			on r.RQMTID = rs.RQMTID
			left join RQMTSet_RQMTSystem rsrs
			on rsrs.RQMTSystemID = rs.RQMTSystemID
			left join RQMTSet rset
			on rset.RQMTSetID = rsrs.RQMTSetID
			left join WorkArea_System was
			on rset.WorkArea_SystemId = was.WorkArea_SystemId;'
		end;

	set @sql = @sql + '

		select rst.AORReleaseID,
		wit.WORKITEM_TASKID,
		wit.WORKITEMID,
		wit.TASK_NUMBER,
		wit.WORKITEMTYPEID,
		wit.STATUSID,
		wit.ASSIGNEDRESOURCEID,
		wit.AssignedToRankID,
		wit.COMPLETIONPERCENT
	into #SubTaskData
	from WORKITEM_TASK wit
	join AORReleaseSubTask rst
	on wit.WORKITEM_TASKID = rst.WORKITEMTASKID
	left join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	left join WORKITEM wi
	on wit.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	;

	select rst.AORReleaseID,
	wi.WORKITEMID,
		wi.WORKITEMTYPEID,
		wi.STATUSID,
		wi.ASSIGNEDRESOURCEID,
		wi.AssignedToRankID,
		wi.COMPLETIONPERCENT
	into #TaskData
	from WORKITEM wi
	join AORReleaseTask rst
	on wi.WORKITEMID = rst.WORKITEMID
	left join AORRelease arl
	on rst.AORReleaseID = arl.AORReleaseID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	and not exists (
		select 1
		from #SubTaskData
		where AORReleaseID = rst.AORReleaseID
	)
	;

	select *
	into #WTData
	from (
		select AORReleaseID,
			WORKITEM_TASKID as WorkTaskID,
			WORKITEMTYPEID,
			STATUSID,
			ASSIGNEDRESOURCEID,
			AssignedToRankID,
			COMPLETIONPERCENT,
			(
				select count(*)
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = st.WORKITEM_TASKID
				and FieldChanged = ''Status''
				and (OldValue in (''Ready for Review'',''Review Complete'',''Checked In'') or NewValue in (''Ready for Review'',''Review Complete'',''Checked In''))
			) as TestingHistory,
			(
				select count(*)
				from WORKITEM_TASK_HISTORY
				where WORKITEM_TASKID = st.WORKITEM_TASKID
				and FieldChanged = ''Status''
			) as StatusMovement
		from #SubTaskData st
		union all
		select AORReleaseID,
		WORKITEMID as WorkTaskID,
			WORKITEMTYPEID,
			STATUSID,
			ASSIGNEDRESOURCEID,
			AssignedToRankID,
			COMPLETIONPERCENT,
			(
				select count(*)
				from WorkItem_History
				where WORKITEMID = td.WORKITEMID
				and FieldChanged = ''Status''
				and (OldValue in (''Ready for Review'',''Review Complete'',''Checked In'') or NewValue in (''Ready for Review'',''Review Complete'',''Checked In''))
			) as TestingHistory,
			(
				select count(*)
				from WorkItem_History
				where WORKITEMID = td.WORKITEMID
				and FieldChanged = ''Status''
			) as StatusMovement
		from #TaskData td
	) a;

	select a.*,
		pdp.PDDTDR_PHASEID,
		pdp.PDDTDR_PHASE,
		case when a.AssignedToRankID = 27 then 1 else 0 end as [1],
		case when a.AssignedToRankID = 28 then 1 else 0 end as [2],
		case when a.AssignedToRankID = 38 then 1 else 0 end as [3],
		case when a.AssignedToRankID = 29 then 1 else 0 end as [4],
		case when a.AssignedToRankID = 30 then 1 else 0 end as [5+],
		case when a.AssignedToRankID = 31 then 1 else 0 end as [6]
	into #WorkTaskData
	from #WTData a
	join WORKITEMTYPE wac
	on a.WORKITEMTYPEID = wac.WORKITEMTYPEID
	left join PDDTDR_PHASE pdp
	on wac.PDDTDR_PHASEID = pdp.PDDTDR_PHASEID;

	with w_PDDTDR_Status_WP as (
	select AORReleaseID,
	a.PDDTDR_PHASEID,
		a.PDDTDR_PHASE,
		a.[Workload Priority],
		case when
				(select count(*)
				from WORKITEMTYPE wac
				join AORRelease arl
				on wac.WorkloadAllocationID = arl.WorkloadAllocationID
				where wac.PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and arl.AORReleaseID = a.AORReleaseID) = 0 then ''NA''
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and STATUSID in (9,10)) = --Deployed,Closed
					(select count(*)
					from #WorkTaskData
					where PDDTDR_PHASEID = a.PDDTDR_PHASEID)
					and (select count(*)
						from #WorkTaskData
						where PDDTDR_PHASEID = a.PDDTDR_PHASEID) > 0 then ''Complete''
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and TestingHistory > 0
				) > 0 then ''Testing''
			when
				round((select cast(count(*) as float)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and StatusMovement > 0) /
					nullif((select cast(count(*) as float)
					from #WorkTaskData
					where PDDTDR_PHASEID = a.PDDTDR_PHASEID), 0) * 100, 0) >= 10 then ''Progressing/In Work (Healthy Progress)''
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and StatusMovement > 0) > 0 then ''Progressing/In Work''
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and STATUSID = 1 --New
				and ASSIGNEDRESOURCEID not in (67,68)
				and StatusMovement = 0) > 0 then ''Ready for Work'' --Intake.IT,Intake.Bus
			when
				(select count(*)
				from #WorkTaskData
				where PDDTDR_PHASEID = a.PDDTDR_PHASEID
				and STATUSID != 6) = 0 then ''Not Ready'' --On Hold
			else ''''
		end as [PD2TDR Status]
	from (
		select AORReleaseID,
		pdp.PDDTDR_PHASEID,
			pdp.PDDTDR_PHASE,
			isnull(convert(nvarchar(10), sum([1])) + ''.'' + convert(nvarchar(10), sum([2])) + ''.'' + convert(nvarchar(10), sum([3])) + ''.'' + convert(nvarchar(10), sum([4])) + ''.'' + convert(nvarchar(10), sum([5+])) + ''.'' + convert(nvarchar(10), sum([6])) + '' ('' + convert(nvarchar(10), sum([1]) + sum([2]) + sum([3]) + sum([4]) + sum([5+])) + '', '' + convert(nvarchar(10), round(cast(sum([6]) as float) / nullif(cast(sum([1]) + sum([2]) + sum([3]) + sum([4]) + sum([5+]) + sum([6]) as float), 0) * 100, 0)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as [Workload Priority],
			pdp.SORT_ORDER
		from PDDTDR_PHASE pdp
		left join #WorkTaskData wtd
		on pdp.PDDTDR_PHASEID = wtd.PDDTDR_PHASEID
		group by AORReleaseID,
		pdp.PDDTDR_PHASEID, pdp.PDDTDR_PHASE, pdp.SORT_ORDER
	) a
	)
	SELECT AORReleaseID
	, [2] AS PlanningStatus
	, [3] AS DesignStatus
	, [4] AS DevelopStatus
	, [5] AS TestStatus
	, [6] AS DeployStatus
	, [7] AS ReviewStatus
	, [Planning] AS PlanningWP
	, [Design]  AS DesignWP
	, [Develop] AS DevelopWP
	, [Test]  AS TestWP
	, [Deploy]  AS DeployWP
	, [Review] AS ReviewWP
	into #WorkPrioStatus
	FROM
	(SELECT PDDTDR_PHASEID, PDDTDR_PHASE, AORReleaseID , [Workload Priority],[PD2TDR Status]
	FROM w_PDDTDR_Status_WP) p
	PIVOT  ( MAX ([PD2TDR Status])
		FOR PDDTDR_PHASEID IN ( [2], [3], [4], [5], [6], [7] )) AS pvtS
	PIVOT  ( MAX ([Workload Priority])
		FOR PDDTDR_PHASE IN  ( [Planning], [Design], [Develop], [Test], [Deploy], [Review] )) AS pvtWP
	ORDER BY AORReleaseID;


	select distinct
		arl.AORReleaseID,
		pddwps.PlanningStatus,
		case when pddwps.PlanningStatus = ''NA'' then 7
		when pddwps.PlanningStatus = ''Complete'' then 6
		when pddwps.PlanningStatus = ''Testing'' then 5
		when pddwps.PlanningStatus = ''Progressing/In Work (Healthy Progress)'' then 4
		when pddwps.PlanningStatus = ''Progressing/In Work'' then 3
		when pddwps.PlanningStatus = ''Ready for Work'' then 2
		when pddwps.PlanningStatus = ''Not Ready'' then 1
		else null
		end as PlanningStatusStage,
		pddwps.DesignStatus,
		case when pddwps.DesignStatus = ''NA'' then 7
		when pddwps.DesignStatus = ''Complete'' then 6
		when pddwps.DesignStatus = ''Testing'' then 5
		when pddwps.DesignStatus = ''Progressing/In Work (Healthy Progress)'' then 4
		when pddwps.DesignStatus = ''Progressing/In Work'' then 3
		when pddwps.DesignStatus = ''Ready for Work'' then 2
		when pddwps.DesignStatus = ''Not Ready'' then 1
		else null
		end as DesignStatusStage,
		pddwps.DevelopStatus,
		case when pddwps.DevelopStatus = ''NA'' then 7
		when pddwps.DevelopStatus = ''Complete'' then 6
		when pddwps.DevelopStatus = ''Testing'' then 5
		when pddwps.DevelopStatus = ''Progressing/In Work (Healthy Progress)'' then 4
		when pddwps.DevelopStatus = ''Progressing/In Work'' then 3
		when pddwps.DevelopStatus = ''Ready for Work'' then 2
		when pddwps.DevelopStatus = ''Not Ready'' then 1
		else null
		end as DevelopStatusStage,
		pddwps.TestStatus,
		case when pddwps.TestStatus = ''NA'' then 7
		when pddwps.TestStatus = ''Complete'' then 6
		when pddwps.TestStatus = ''Testing'' then 5
		when pddwps.TestStatus = ''Progressing/In Work (Healthy Progress)'' then 4
		when pddwps.TestStatus = ''Progressing/In Work'' then 3
		when pddwps.TestStatus = ''Ready for Work'' then 2
		when pddwps.TestStatus = ''Not Ready'' then 1
		else null
		end as TestStatusStage,
		pddwps.DeployStatus,
		case when pddwps.DeployStatus = ''NA'' then 7
		when pddwps.DeployStatus = ''Complete'' then 6
		when pddwps.DeployStatus = ''Testing'' then 5
		when pddwps.DeployStatus = ''Progressing/In Work (Healthy Progress)'' then 4
		when pddwps.DeployStatus = ''Progressing/In Work'' then 3
		when pddwps.DeployStatus = ''Ready for Work'' then 2
		when pddwps.DeployStatus = ''Not Ready'' then 1
		else null
		end as DeployStatusStage,
		pddwps.ReviewStatus,
		case when pddwps.ReviewStatus = ''NA'' then 7
		when pddwps.ReviewStatus = ''Complete'' then 6
		when pddwps.ReviewStatus = ''Testing'' then 5
		when pddwps.ReviewStatus = ''Progressing/In Work (Healthy Progress)'' then 4
		when pddwps.ReviewStatus = ''Progressing/In Work'' then 3
		when pddwps.ReviewStatus = ''Ready for Work'' then 2
		when pddwps.ReviewStatus = ''Not Ready'' then 1
		else null
		end as ReviewStatusStage
	into #PD2TDRStatus
	from AORCR acr
	left join AORReleaseCR arc
	on acr.CRID = arc.CRID
	left join AORRelease arl
	on arc.AORReleaseID = arl.AORReleaseID
	left join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	left join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	left join WTS_SYSTEM_CONTRACT wsc
	on wi.WTS_SYSTEMID = wsc.WTS_SYSTEMID
	left join AOR
	on arl.AORID = AOR.AORID
	left join #WorkPrioStatus pddwps
	on arl.AORReleaseID = pddwps.AORReleaseID
	where isnull(wsc.[Primary], 1) = 1
	and isnull(AOR.Archive, 0) = 0
	;

			select wi.WORKITEMID,
				AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				wal.WorkloadAllocation,
				wal.WorkloadAllocationID,
				isnull(rta.CascadeAOR, 0) as CascadeAOR,
				isnull(awt.AORWorkTypeName, ''No AOR Type'') as AORType,
				isnull(arl.AORWorkTypeID,-1) as AORWorkTypeID,
				max(pds.ReviewStatusStage) as ReviewStatusStage,
				max(pds.DeployStatusStage) as DeployStatusStage,
				max(pds.TestStatusStage) as TestStatusStage,
				max(pds.DevelopStatusStage) as DevelopStatusStage,
				max(pds.DesignStatusStage) as DesignStatusStage,
				max(pds.PlanningStatusStage) as PlanningStatusStage
			into #TaskAOR
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseTask rta
			on arl.AORReleaseID = rta.AORReleaseID
			join WORKITEM wi
			on rta.WORKITEMID = wi.WORKITEMID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join WorkloadAllocation wal
			on arl.WorkloadAllocationID = wal.WorkloadAllocationID
			left join #PD2TDRStatus pds
			on rta.AORReleaseID = pds.AORReleaseID
			where arl.[Current] = 1
			and AOR.Archive = 0
			group by wi.WORKITEMID,
				AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				wal.WorkloadAllocation,
				wal.WorkloadAllocationID,
				isnull(rta.CascadeAOR, 0),
				isnull(awt.AORWorkTypeName, ''No AOR Type''),
				isnull(arl.AORWorkTypeID,-1)
			;

			select wi.WORKITEM_TASKID,
				AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				wal.WorkloadAllocation,
				wal.WorkloadAllocationID,
				isnull(rta.CascadeAOR, 0) as CascadeAOR,
				isnull(awt.AORWorkTypeName, ''No AOR Type'') as AORType,
				isnull(arl.AORWorkTypeID,-1) as AORWorkTypeID,
				max(pds.ReviewStatusStage) as ReviewStatusStage,
				max(pds.DeployStatusStage) as DeployStatusStage,
				max(pds.TestStatusStage) as TestStatusStage,
				max(pds.DevelopStatusStage) as DevelopStatusStage,
				max(pds.DesignStatusStage) as DesignStatusStage,
				max(pds.PlanningStatusStage) as PlanningStatusStage
			into #SubTaskAOR
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
			left join WorkloadAllocation wal
			on arl.WorkloadAllocationID = wal.WorkloadAllocationID
			left join #PD2TDRStatus pds
			on rsta.AORReleaseID = pds.AORReleaseID
			where arl.[Current] = 1
			and AOR.Archive = 0
			group by wi.WORKITEM_TASKID,
				AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				wal.WorkloadAllocation,
				wal.WorkloadAllocationID,
				isnull(rta.CascadeAOR, 0),
				isnull(awt.AORWorkTypeName, ''No AOR Type''),
				isnull(arl.AORWorkTypeID,-1)
			;';

if charindex('SESSIONDATA', upper(@sql_from)) > 0
		begin
			set @sql = @sql + '
			select WORKITEMID, ReleaseSessionID, ReleaseSession, StartDate, EndDate
			into #SessionData
			from (
				--Created
				select wi.WORKITEMID, rs.ReleaseSessionID, rs.ReleaseSession, convert(date, rs.StartDate) as StartDate, (dateadd(day, rs.Duration, convert(date, rs.StartDate))) as EndDate
				from WORKITEM wi
				join ReleaseSession rs
				on wi.ProductVersionID = rs.ProductVersionID and convert(date, wi.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
				union
				--Closed
				select wi.WORKITEMID, rs.ReleaseSessionID, rs.ReleaseSession, convert(date, rs.StartDate) as StartDate, (dateadd(day, rs.Duration, convert(date, rs.StartDate))) as EndDate
				from WORKITEM wi
				join WorkItem_History wih
				on wi.WORKITEMID = wih.WORKITEMID
				join ReleaseSession rs
				on wi.ProductVersionID = rs.ProductVersionID and convert(date, wih.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
				where wih.FieldChanged = ''Status''
				and wih.NewValue = ''Closed''
			) a;

			create nonclustered index idx_SessionData ON #SessionData (WORKITEMID, ReleaseSessionID, ReleaseSession);

			select WORKITEM_TASKID, ReleaseSessionID, ReleaseSession, StartDate, EndDate
			into #SessionDataSub
			from (
				select wit.WORKITEM_TASKID, rs.ReleaseSessionID, rs.ReleaseSession, convert(date, rs.StartDate) as StartDate, (dateadd(day, rs.Duration, convert(date, rs.StartDate))) as EndDate
				from WORKITEM_TASK wit
				join ReleaseSession rs
				on wit.ProductVersionID = rs.ProductVersionID and convert(date, wit.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
				union
				select wit.WORKITEM_TASKID, rs.ReleaseSessionID, rs.ReleaseSession, convert(date, rs.StartDate) as StartDate, (dateadd(day, rs.Duration, convert(date, rs.StartDate))) as EndDate
				from WORKITEM_TASK wit
				join WorkItem_Task_History wth
				on wit.WORKITEM_TASKID = wth.WORKITEM_TASKID
				join ReleaseSession rs
				on wit.ProductVersionID = rs.ProductVersionID and convert(date, wth.CREATEDDATE) between convert(date, rs.StartDate) and (dateadd(day, rs.Duration, convert(date, rs.StartDate)))
				where wth.FieldChanged = ''Status''
				and wth.NewValue = ''Closed''
			) b;

			create nonclustered index idx_SessionDataSub ON #SessionDataSub (WORKITEM_TASKID, ReleaseSessionID, ReleaseSession);
			';
		end;

if charindex('WORKTASKMILESTONES', upper(@sql_from)) > 0
		begin
			set @sql = @sql + '
			select wi.WORKITEMID,
				convert(nvarchar, a.CREATEDDATE, 101) as InProgressDate,
				convert(nvarchar, b.CREATEDDATE, 101) as DeployedDate,
				convert(nvarchar, c.CREATEDDATE, 101) as ReadyForReviewDate,
				convert(nvarchar, d.CREATEDDATE, 101) as ClosedDate
			into #WorkTaskMilestones
			from WORKITEM wi
			left join (
				select wih.WORKITEMID, wih.CREATEDDATE, row_number() over(partition by wih.WORKITEMID order by wih.CREATEDDATE) as rn
				from WorkItem_History wih
				where wih.FieldChanged = ''Status''
				and wih.NewValue = ''In Progress''
			) a
			on wi.WORKITEMID = a.WORKITEMID
			left join (
				select wih.WORKITEMID, wih.CREATEDDATE, row_number() over(partition by wih.WORKITEMID order by wih.CREATEDDATE) as rn
				from WorkItem_History wih
				where wih.FieldChanged = ''Status''
				and wih.NewValue = ''Deployed''
			) b
			on wi.WORKITEMID = b.WORKITEMID
			left join (
				select wih.WORKITEMID, wih.CREATEDDATE, row_number() over(partition by wih.WORKITEMID order by wih.CREATEDDATE) as rn
				from WorkItem_History wih
				where wih.FieldChanged = ''Status''
				and wih.NewValue = ''Ready for Review''
			) c
			on wi.WORKITEMID = c.WORKITEMID
			left join (
				select wih.WORKITEMID, wih.CREATEDDATE, row_number() over(partition by wih.WORKITEMID order by wih.CREATEDDATE DESC) as rn
				from WorkItem_History wih
				where wih.FieldChanged = ''Status''
				and wih.NewValue = ''Closed''
			) d
			on wi.WORKITEMID = d.WORKITEMID
			where isnull(a.rn, 1) = 1
			and isnull(b.rn, 1) = 1
			and isnull(c.rn, 1) = 1
			and isnull(d.rn, 1) = 1
			and (isnull(a.rn, 0) + isnull(b.rn, 0) + isnull(c.rn, 0) + isnull(d.rn, 0)) > 0;

			select wit.WORKITEM_TASKID,
				convert(nvarchar, a.CREATEDDATE, 101) as InProgressDate,
				convert(nvarchar, b.CREATEDDATE, 101) as DeployedDate,
				convert(nvarchar, c.CREATEDDATE, 101) as ReadyForReviewDate,
				convert(nvarchar, d.CREATEDDATE, 101) as ClosedDate
			into #WorkTaskMilestonesSub
			from WORKITEM_TASK wit
			left join (
				select wth.WORKITEM_TASKID, wth.CREATEDDATE, row_number() over(partition by wth.WORKITEM_TASKID order by wth.CREATEDDATE) as rn
				from WORKITEM_TASK_HISTORY wth
				where wth.FieldChanged = ''Status''
				and wth.NewValue = ''In Progress''
			) a
			on wit.WORKITEM_TASKID = a.WORKITEM_TASKID
			left join (
				select wth.WORKITEM_TASKID, wth.CREATEDDATE, row_number() over(partition by wth.WORKITEM_TASKID order by wth.CREATEDDATE) as rn
				from WORKITEM_TASK_HISTORY wth
				where wth.FieldChanged = ''Status''
				and wth.NewValue = ''Deployed''
			) b
			on wit.WORKITEM_TASKID = b.WORKITEM_TASKID
			left join (
				select wth.WORKITEM_TASKID, wth.CREATEDDATE, row_number() over(partition by wth.WORKITEM_TASKID order by wth.CREATEDDATE) as rn
				from WORKITEM_TASK_HISTORY wth
				where wth.FieldChanged = ''Status''
				and wth.NewValue = ''Ready for Review''
			) c
			on wit.WORKITEM_TASKID = c.WORKITEM_TASKID
			left join (
				select wth.WORKITEM_TASKID, wth.CREATEDDATE, row_number() over(partition by wth.WORKITEM_TASKID order by wth.CREATEDDATE) as rn
				from WORKITEM_TASK_HISTORY wth
				where wth.FieldChanged = ''Status''
				and wth.NewValue = ''Closed''
			) d
			on wit.WORKITEM_TASKID = d.WORKITEM_TASKID
			where isnull(a.rn, 1) = 1
			and isnull(b.rn, 1) = 1
			and isnull(c.rn, 1) = 1
			and isnull(d.rn, 1) = 1
			and (isnull(a.rn, 0) + isnull(b.rn, 0) + isnull(c.rn, 0) + isnull(d.rn, 0)) > 0;
			';
		end;

	set @sql_with = '
		with w_user_filter as (
			select FilterID
			,FilterTypeID
			from User_Filter uf
			where uf.SessionID = ''' + @SessionID + '''
			and uf.UserName = ''' + @UserName + '''
			and uf.FilterTypeID IN (1,4)
		),
		w_aor as (
			select arr.WTS_RESOURCEID,
				art.WORKITEMID
			from AORReleaseTask art
			join AORReleaseResource arr
			on art.AORReleaseID = arr.AORReleaseID
			join AORRelease arl
			on art.AORReleaseID = arl.AORReleaseID
			join AOR
			on arl.AORID = AOR.AORID
			where charindex('','' + convert(nvarchar(10), arr.WTS_RESOURCEID) + '','', '',' + @QFAffiliated + ','') > 0
			and arl.[Current] = 1
			and AOR.Archive = 0
		),
		w_system as (
			select wsy.BusWorkloadManagerID as WTS_RESOURCEID,
				wi.WORKITEMID
			from WTS_SYSTEM wsy
			join WORKITEM wi
			on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
			where charindex('','' + convert(nvarchar(10), wsy.BusWorkloadManagerID) + '','', '',' + @QFAffiliated + ','') > 0
			union all
			select wsy.DevWorkloadManagerID as WTS_RESOURCEID,
				wi.WORKITEMID
			from WTS_SYSTEM wsy
			join WORKITEM wi
			on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
			where charindex('','' + convert(nvarchar(10), wsy.DevWorkloadManagerID) + '','', '',' + @QFAffiliated + ','') > 0
			union all
			select wsr.WTS_RESOURCEID,
				wi.WORKITEMID
			from WTS_SYSTEM_RESOURCE wsr
			join WORKITEM wi
			on wsr.WTS_SYSTEMID = wi.WTS_SYSTEMID and wsr.ProductVersionID = wi.ProductVersionID
			where charindex('','' + convert(nvarchar(10), wsr.WTS_RESOURCEID) + '','', '',' + @QFAffiliated + ','') > 0
		),
		';

		set @sql_with = @sql_with + '
		w_filtered_sub_tasks as (
			select wit.[WORKITEM_TASKID]
      ,wit.[WORKITEMID]
      ,wit.[TASK_NUMBER]
	  ';

			if (charindex('WORKITEMID', upper(@sql_select)) = 0 and charindex('ASSIGNEDTO_ID', upper(@sql_select)) > 0)
				begin
					set @sql_with = @sql_with + '
					,case when ar.AORResourceTeam = 1 then arrt.ResourceID else wit.[ASSIGNEDRESOURCEID] end as ASSIGNEDRESOURCEID';
				end;
			else
				begin
				  set @sql_with = @sql_with + '
				  ,wit.[ASSIGNEDRESOURCEID]
				  ';
				end;

	set @sql_with = @sql_with + '
      ,wit.[ESTIMATEDSTARTDATE]
      ,wit.[ACTUALSTARTDATE]
      ,wit.[ACTUALENDDATE]
      ,wit.[PLANNEDHOURS]
      ,wit.[ACTUALHOURS]
      ,wit.[COMPLETIONPERCENT]
      ,wit.[WORKITEMTYPEID]
      ,wit.[STATUSID]
      ,wit.[TITLE]
      ,wit.[DESCRIPTION]
      ,wit.[SORT_ORDER]
      ,wit.[ARCHIVE]
      ,wit.[CREATEDBY]
      ,wit.[CREATEDDATE]
      ,wit.[UPDATEDBY]
      ,wit.[UPDATEDDATE]
      ,wit.[SubmittedByID]
      ,wit.[PrimaryResourceID]
      ,wit.[PRIORITYID]
      ,wit.[EstimatedEffortID]
      ,wit.[ActualEffortID]
      ,wit.[BusinessRank]
      ,wit.[SecondaryResourceID]
      ,wit.[SRNumber]
      ,wit.[PRIMARYBUSRESOURCEID]
      ,wit.[SECONDARYBUSRESOURCEID]
      ,wit.[AssignedToRankID]
      ,wit.[ProductVersionID]
      ,wit.[NeedDate]
      ,wit.[BusinessReview]
	  , s.[STATUS]
	  ,s.[SORT_ORDER] as StatusStage
	  , p.[PRIORITY]
	  , ao.ORGANIZATION,
			tawt.AORID,
			tawt.AORName,
			tawt.AORReleaseID,
			convert(int, rta.CascadeAOR) as CascadeAOR,
			tawt. AORType,
			tawt.ReviewStatusStage,
			tawt.DeployStatusStage,
			tawt.TestStatusStage,
			tawt.DevelopStatusStage,
			tawt.DesignStatusStage,
			tawt.PlanningStatusStage,
			tawt2.AORID as AORID2,
			tawt2.AORName as AORName2,
			tawt2.AORReleaseID as AORReleaseID2,
			tawt2.WorkloadAllocation,
			tawt2.WorkloadAllocationID,
			convert(int, rta.CascadeAOR) as CascadeAOR2,
			tawt2.AORType as AORType2,
			tawt2.ReviewStatusStage as ReviewStatusStage2,
			tawt2.DeployStatusStage as DeployStatusStage2,
			tawt2.TestStatusStage as TestStatusStage2,
			tawt2.DevelopStatusStage as DevelopStatusStage2,
			tawt2.DesignStatusStage as DesignStatusStage2,
			tawt2.PlanningStatusStage as PlanningStatusStage2
			';

			set @sql_with = @sql_with + '
			from WORKITEM_TASK wit
			join WORKITEM wi
			on wit.WORKITEMID = wi.WORKITEMID
			join [STATUS] s
			on wit.STATUSID = s.STATUSID
			left join [PRIORITY] p
			on wit.PRIORITYID = p.PRIORITYID
			join WTS_RESOURCE ar
			on wit.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
			';

			if (charindex('WORKITEMID', upper(@sql_select)) = 0 and charindex('ASSIGNEDTO_ID', upper(@sql_select)) > 0)
				begin
					set @sql_with = @sql_with + '
					left join AORReleaseResourceTeam arrt
					on ar.WTS_RESOURCEID = arrt.[TeamResourceID]
					';
				end;

			set @sql_with = @sql_with + '
			join ORGANIZATION ao
			on ar.ORGANIZATIONID = ao.ORGANIZATIONID
			join w_user_filter uf
			on wit.WORKITEM_TASKID = uf.FilterID AND uf.FilterTypeID = 4
			left join #SubTaskAOR tawt
			on wiT.WORKITEM_TASKID = tawt.WORKITEM_TASKID
			and tawt.AORWorkTypeID in (1,-1) --Workload MGMT
			left join #SubTaskAOR tawt2
			on wiT.WORKITEM_TASKID = tawt2.WORKITEM_TASKID
			and tawt2.AORWorkTypeID = 2 --Release/Deployment MGMT
			left join AORReleaseTask rta
			on tawt.AORReleaseID = rta.AORReleaseID
			and wit.WORKITEMID = rta.WORKITEMID
			';



			if @QFAffiliated != ''
				begin
					set @sql_with = @sql_with + '
						where (wit.ASSIGNEDRESOURCEID IN (' + @QFAffiliated +  ')
						or wit.PrimaryResourceID IN (' + @QFAffiliated +  ')
						or wi.ASSIGNEDRESOURCEID IN (' + @QFAffiliated +  ')
						or wi.PRIMARYRESOURCEID IN (' + @QFAffiliated +  ')
						or exists (
							select 1
							from w_aor aor
							join w_system wsy
							on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
							where aor.WORKITEMID = wit.WORKITEMID
						)
						or exists (
							select 1
							from #AffiliatedResourceTeamUser artu
							join WorkType_WTS_RESOURCE rgr
							on artu.ResourceID = rgr.WTS_RESOURCEID
							where artu.TeamResourceID = ar.WTS_RESOURCEID
							and rgr.WorkTypeID = wi.WorkTypeID
						)
						)';
					end;

			if @QFStatus != ''
				begin
					set @sql_with = @sql_with + case when @QFAffiliated != '' then ' and' else ' where' end + '
						wit.STATUSID in (' + @QFStatus + ')';
				end;

			if @QFBusinessReview = '1'
				begin
					set @sql_with = @sql_with + 'and wit.BusinessReview = 1';
				end;

		--if (charindex('WORKITEMID', upper(@sql_select)) = 0 and charindex('ASSIGNEDTO_ID', upper(@sql_select)) = 0)
		--		begin
		--			set @sql_with = @sql_with + '
		--			and ar.aorresourceteam = 0';
		--		end;
		if (charindex('TASK_NUMBER', upper(@sql_select_level)) = 0 and charindex('PRIMARY_TASK', upper(@sql_select)) > 0)
			begin
					set @sql_with = @sql_with + '
						and wit.WORKITEMID = 0 ';
					end;

	set @sql_with = @sql_with + '
		),
		w_filtered_tasks as (
			select distinct wi.[WORKITEMID]
      ,wi.[WORKITEMTYPEID]
      ,wi.[WTS_SYSTEMID]
      ,wi.[PRIORITYID]
      ,wi.[ALLOCATIONID]
	  ';

			if (charindex('WORKITEMID', upper(@sql_select)) = 0 and charindex('ASSIGNEDTO_ID', upper(@sql_select)) > 0)
				begin
					set @sql_with = @sql_with + '
					,case when ar.AORResourceTeam = 1 then arrt.ResourceID else wi.[ASSIGNEDRESOURCEID] end as ASSIGNEDRESOURCEID';
				end;
			else
				begin
				  set @sql_with = @sql_with + '
				  ,wi.[ASSIGNEDRESOURCEID]
				  ';
				end;

	set @sql_with = @sql_with + '
      ,wi.[PRIMARYRESOURCEID]
      ,wi.[SECONDARYRESOURCEID]
      ,wi.[RESOURCEPRIORITYRANK]
      ,wi.[STATUSID]
      ,wi.[NEEDDATE]
      ,wi.[ESTIMATEDHOURS]
      ,wi.[ESTIMATEDCOMPLETIONDATE]
      ,wi.[COMPLETIONPERCENT]
      ,wi.[TITLE]
      ,wi.[DESCRIPTION]
      ,wi.[WORKREQUESTID]
      ,wi.[BUGTRACKER_ID]
      ,wi.[ProductVersionID]
      ,wi.[MenuTypeID]
      ,wi.[MenuNameID]
      ,wi.[Production]
      ,wi.[SR_Number]
      ,wi.[Reproduced_Biz]
      ,wi.[Reproduced_Dev]
      ,wi.[Deployed_Comm]
      ,wi.[Deployed_Test]
      ,wi.[Deployed_Prod]
      ,wi.[DeployedBy_CommID]
      ,wi.[DeployedBy_TestID]
      ,wi.[DeployedBy_ProdID]
      ,wi.[DeployedDate_Comm]
      ,wi.[DeployedDate_Test]
      ,wi.[DeployedDate_Prod]
      ,wi.[PlannedDesignStart]
      ,wi.[PlannedDevStart]
      ,wi.[ActualDesignStart]
      ,wi.[ActualDevStart]
      ,wi.[CVTStep]
      ,wi.[CVTStatus]
      ,wi.[TesterID]
      ,wi.[WorkTypeID]
      ,wi.[WorkloadGroupID]
      ,wi.[WorkAreaID]
      ,wi.[ARCHIVE]
      ,wi.[CREATEDBY]
      ,wi.[CREATEDDATE]
      ,wi.[UPDATEDBY]
      ,wi.[UPDATEDDATE]
      ,wi.[SubmittedByID]
      ,wi.[IVTRequired]
      ,wi.[EstimatedEffortID]
      ,wi.[ActualEffortID]
      ,wi.[PrimaryBusinessResourceID]
      ,wi.[SecondaryResourceRank]
      ,wi.[PrimaryBusinessRank]
      ,wi.[Signed_Bus]
      ,wi.[SignedBy_BusID]
      ,wi.[SignedDate_Bus]
      ,wi.[Signed_Dev]
      ,wi.[SignedBy_DevID]
      ,wi.[SignedDate_Dev]
      ,wi.[Recurring]
      ,wi.[ProductionStatusID]
      ,wi.[PDDTDR_PHASEID]
      ,wi.[SecondaryBusinessResourceID]
      ,wi.[SecondaryBusinessRank]
      ,wi.[ActualCompletionDate]
      ,wi.[FromBugTracker]
      ,wi.[AssignedToRankID]
      ,wi.[BusinessReview]
	  , s.[STATUS]
	  ,s.[SORT_ORDER] as StatusStage
	  , p.[PRIORITY]
	  , ao.ORGANIZATION,
			tawt.AORID,
			tawt.AORName,
			tawt.AORReleaseID,
			convert(int, tawt.CascadeAOR) as CascadeAOR,
			tawt. AORType,
			tawt.ReviewStatusStage,
			tawt.DeployStatusStage,
			tawt.TestStatusStage,
			tawt.DevelopStatusStage,
			tawt.DesignStatusStage,
			tawt.PlanningStatusStage,
			tawt2.AORID as AORID2,
			tawt2.AORName as AORName2,
			tawt2.AORReleaseID as AORReleaseID2,
			tawt2.WorkloadAllocation,
			tawt2.WorkloadAllocationID,
			convert(int, tawt2.CascadeAOR) as CascadeAOR2,
			tawt2.AORType as AORType2,
			tawt2.ReviewStatusStage as ReviewStatusStage2,
			tawt2.DeployStatusStage as DeployStatusStage2,
			tawt2.TestStatusStage as TestStatusStage2,
			tawt2.DevelopStatusStage as DevelopStatusStage2,
			tawt2.DesignStatusStage as DesignStatusStage2,
			tawt2.PlanningStatusStage as PlanningStatusStage2
			';

			set @sql_with = @sql_with + '
			from WORKITEM wi
			left join WORKITEM_TASK wit
			on wi.WORKITEMID = wit.WORKITEMID
			join [STATUS] s
			on wi.STATUSID = s.STATUSID
			join [PRIORITY] p
			on wi.PRIORITYID = p.PRIORITYID
			join WTS_RESOURCE ar
			on wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
			';

			if (charindex('WORKITEMID', upper(@sql_select)) = 0 and charindex('ASSIGNEDTO_ID', upper(@sql_select)) > 0)
				begin
					set @sql_with = @sql_with + '
					left join AORReleaseResourceTeam arrt
					on ar.WTS_RESOURCEID = arrt.[TeamResourceID]
					';
				end;

			set @sql_with = @sql_with + '
			join ORGANIZATION ao
			on ar.ORGANIZATIONID = ao.ORGANIZATIONID
			join w_user_filter uf
			on wi.WORKITEMID = uf.FilterID AND uf.FilterTypeID = 1
			left join #TaskAOR tawt
			on wi.WORKITEMID = tawt.WORKITEMID
			and tawt.AORWorkTypeID in (1,-1) --Workload MGMT
			left join #TaskAOR tawt2
			on wi.WORKITEMID = tawt2.WORKITEMID
			and tawt2.AORWorkTypeID = 2 --Release/Deployment MGMT
			';

			if @QFAffiliated != ''
				begin
					set @sql_with = @sql_with + '
						where (wi.ASSIGNEDRESOURCEID IN (' + @QFAffiliated +  ')
						or wi.PRIMARYRESOURCEID IN (' + @QFAffiliated +  ')
						or wit.ASSIGNEDRESOURCEID IN (' + @QFAffiliated +  ')
						or wit.PrimaryResourceID IN (' + @QFAffiliated +  ')
						or exists (
							select 1
							from w_aor aor
							join w_system wsy
							on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
							where aor.WORKITEMID = wi.WORKITEMID
						)
						or exists (
							select 1
							from #AffiliatedResourceTeamUser artu
							join WorkType_WTS_RESOURCE rgr
							on artu.ResourceID = rgr.WTS_RESOURCEID
							where artu.TeamResourceID = ar.WTS_RESOURCEID
							and rgr.WorkTypeID = wi.WorkTypeID
						)
						)';
				end;

			if @QFStatus != ''
				begin
					set @sql_with = @sql_with + case when @QFAffiliated != '' then ' and' else ' where' end + '
						wi.STATUSID in (' + @QFStatus + ')';
				end;

			if @QFBusinessReview = '1'
				begin
					set @sql_with = @sql_with + 'and (wi.[BusinessReview] = 1 or wit.[BusinessReview] = 1)';
				end;

			--if (charindex('WORKITEMID', upper(@sql_select)) > 0 and charindex('ASSIGNEDTO_ID', upper(@sql_select)) = 0)
			--	begin
			--		set @sql_with = @sql_with + '
			--		and ar.aorresourceteam = 0';
			--	end;

		if (charindex('TASK_NUMBER', upper(@sql_select_level)) > 0 and charindex('WI.WORKITEMID', upper(@sql_where_sub)) > 0)
			begin
				set @sql_with = @sql_with + '
						and wi.WORKITEMID = 0 ';
			end;
	set @sql_with = @sql_with + '
		),';

	if charindex('W_AFFILIATED', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_affiliated as (
					select distinct wi.WORKITEMID, wi.WTS_RESOURCEID, wir.USERNAME
					from (
						select wi.WORKITEMID, wi.ASSIGNEDRESOURCEID as WTS_RESOURCEID from WORKITEM wi join w_filtered_tasks wft on wi.WORKITEMID = wft.WORKITEMID
						union all
						select wi.WORKITEMID, wi.PRIMARYRESOURCEID as WTS_RESOURCEID from WORKITEM wi join w_filtered_tasks wft on wi.WORKITEMID = wft.WORKITEMID
						union all
						select aor.WORKITEMID, aor.WTS_RESOURCEID from w_aor aor join w_system wsy on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID join w_filtered_tasks wft on aor.WORKITEMID = wft.WORKITEMID
					) wi
					join WTS_RESOURCE wir
					on wi.WTS_RESOURCEID = wir.WTS_RESOURCEID
				),
				w_affiliated_sub as (
					select distinct wit.WORKITEM_TASKID, wit.WTS_RESOURCEID, wir.USERNAME
					from (
						select wit.WORKITEM_TASKID, wit.ASSIGNEDRESOURCEID as WTS_RESOURCEID from WORKITEM_TASK wit join w_filtered_sub_tasks wft on wit.WORKITEM_TASKID = wft.WORKITEM_TASKID
						union all
						select wit.WORKITEM_TASKID, wit.PrimaryResourceID as WTS_RESOURCEID from WORKITEM_TASK wit join w_filtered_sub_tasks wft on wit.WORKITEM_TASKID = wft.WORKITEM_TASKID
						union all
						select wit.WORKITEM_TASKID, aor.WTS_RESOURCEID from w_aor aor join w_system wsy on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID join WORKITEM_TASK wit on aor.WORKITEMID = wit.WORKITEMID join w_filtered_sub_tasks wft on wit.WORKITEM_TASKID = wft.WORKITEM_TASKID
					) wit
					join WTS_RESOURCE wir
					on wit.WTS_RESOURCEID = wir.WTS_RESOURCEID
				),';
		end;

	set @sql_with = @sql_with + '
		w_exclude_task as (
			select wit.WORKITEMID as Excluded_WorkItemID,' + @sql_select_sub + '
			from w_filtered_tasks wi
			join w_filtered_sub_tasks wit
			on wi.WORKITEMID = wit.WORKITEMID ' +
			@sql_from_sub;

			if @sql_where_sub != ''
				begin
					set @sql_with = @sql_with + '
						where ' + @sql_where_sub;
				end;

			if charindex('JOIN AORRELEASE ARL', upper(@sql_from_sub)) > 0
				begin
					set @sql_with = @sql_with + case when @sql_where_sub != '' then ' and' else ' where' end + '
						(isnull(arl.[Current], 1) = 1 or (select max(convert(int, arl2.[Current])) from AORReleaseTask art2 join AORRelease arl2 on art2.AORReleaseID = arl2.AORReleaseID where art2.WORKITEMID = wi.WORKITEMID) = 0) ';
				end;

		set @sql_with = @sql_with + '
		),
		w_task_rollup as (
			select' + @sql_select;

			if charindex('WORKITEMID', upper(@sql_select)) > 0 and charindex('STATUSID', upper(@sql_select)) > 0 
				begin
					set @sql_with = @sql_with + ', (select count(wi2.SR_Number) from WORKITEM wi2 where wi.SR_Number = wi2.SR_Number) - (select count(wi2.SR_Number) from WORKITEM wi2 where wi.SR_Number = wi2.SR_Number and wi2.STATUSID = 10) as [Unclosed SR Tasks]';
				end;
			
			if charindex('WORKITEMID', upper(@sql_select)) = 0
				begin
					set @sql_with = @sql_with + ', ' + @sql_rollups + ' isnull(sum(1), 0) as Total_Tasks';
				end;


			if charindex('WORKLOAD PRIORITY', upper(@sql_select_level)) > 0
				begin
					if charindex('WORKITEMID', upper(@sql_select)) != 0
						begin
							set @sql_with = @sql_with + ', isnull(max(case when wi.AssignedToRankID = 27 then 1 else 0 end), 0) as [1], isnull(max(case when wi.AssignedToRankID = 28 then 1 else 0 end), 0) as [2], isnull(max(case when wi.AssignedToRankID = 38 then 1 else 0 end), 0) as [3], isnull(max(case when wi.AssignedToRankID = 29 then 1 else 0 end), 0) as [4], isnull(max(case when wi.AssignedToRankID = 30 then 1 else 0 end), 0) as [5+], isnull(max(case when wi.AssignedToRankID = 31 then 1 else 0 end), 0) as [6]';
						end;
					else
						begin
							set @sql_with = @sql_with + ', isnull(sum(case when wi.AssignedToRankID = 27 then 1 else 0 end), 0) as [1], isnull(sum(case when wi.AssignedToRankID = 28 then 1 else 0 end), 0) as [2], isnull(sum(case when wi.AssignedToRankID = 38 then 1 else 0 end), 0) as [3], isnull(sum(case when wi.AssignedToRankID = 29 then 1 else 0 end), 0) as [4], isnull(sum(case when wi.AssignedToRankID = 30 then 1 else 0 end), 0) as [5+], isnull(sum(case when wi.AssignedToRankID = 31 then 1 else 0 end), 0) as [6]';
						end;
				end;
			if charindex('TASK.WORKLOAD.RELEASE STATUS', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with +
					',case when max(wi.StatusStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.StatusStage), -1) and st.StatusType = ''Work'')
						else ''N/A'' end  + ''.'' +
						case when max(wi.PlanningStatusStage) is not null then
							case when max(wi.PlanningStatusStage)  = 7 then ''NA''
							when max(wi.PlanningStatusStage)  = 6 then ''Complete''
							when max(wi.PlanningStatusStage)  = 5 then ''Testing''
							when max(wi.PlanningStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.PlanningStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.PlanningStatusStage)  = 2 then ''Ready for Work''
							when max(wi.PlanningStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DesignStatusStage) is not null then
							case when max(wi.DesignStatusStage)  = 7 then ''NA''
							when max(wi.DesignStatusStage)  = 6 then ''Complete''
							when max(wi.DesignStatusStage)  = 5 then ''Testing''
							when max(wi.DesignStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DesignStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DesignStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DesignStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DevelopStatusStage) is not null then
							case when max(wi.DevelopStatusStage)  = 7 then ''NA''
							when max(wi.DevelopStatusStage)  = 6 then ''Complete''
							when max(wi.DevelopStatusStage)  = 5 then ''Testing''
							when max(wi.DevelopStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DevelopStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DevelopStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DevelopStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.TestStatusStage) is not null then
							case when max(wi.TestStatusStage)  = 7 then ''NA''
							when max(wi.TestStatusStage)  = 6 then ''Complete''
							when max(wi.TestStatusStage)  = 5 then ''Testing''
							when max(wi.TestStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.TestStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.TestStatusStage)  = 2 then ''Ready for Work''
							when max(wi.TestStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DeployStatusStage) is not null then
							case when max(wi.DeployStatusStage)  = 7 then ''NA''
							when max(wi.DeployStatusStage)  = 6 then ''Complete''
							when max(wi.DeployStatusStage)  = 5 then ''Testing''
							when max(wi.DeployStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DeployStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DeployStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DeployStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.ReviewStatusStage) is not null then
							case when max(wi.ReviewStatusStage)  = 7 then ''NA''
							when max(wi.ReviewStatusStage)  = 6 then ''Complete''
							when max(wi.ReviewStatusStage)  = 5 then ''Testing''
							when max(wi.ReviewStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.ReviewStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.ReviewStatusStage)  = 2 then ''Ready for Work''
							when max(wi.ReviewStatusStage)  = 1 then ''Not Ready''
							else null end
						else ''N/A'' end + ''.'' +
						';

						set @sql_with = @sql_with +
						' case when max(wi.PlanningStatusStage2) is not null then
							case when max(wi.PlanningStatusStage2)  = 7 then ''NA''
							when max(wi.PlanningStatusStage2)  = 6 then ''Complete''
							when max(wi.PlanningStatusStage2)  = 5 then ''Testing''
							when max(wi.PlanningStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.PlanningStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.PlanningStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.PlanningStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DesignStatusStage2) is not null then
							case when max(wi.DesignStatusStage2)  = 7 then ''NA''
							when max(wi.DesignStatusStage2)  = 6 then ''Complete''
							when max(wi.DesignStatusStage2)  = 5 then ''Testing''
							when max(wi.DesignStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DesignStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DesignStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DesignStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DevelopStatusStage2) is not null then
							case when max(wi.DevelopStatusStage2)  = 7 then ''NA''
							when max(wi.DevelopStatusStage2)  = 6 then ''Complete''
							when max(wi.DevelopStatusStage2)  = 5 then ''Testing''
							when max(wi.DevelopStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DevelopStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DevelopStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DevelopStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.TestStatusStage2) is not null then
							case when max(wi.TestStatusStage2)  = 7 then ''NA''
							when max(wi.TestStatusStage2)  = 6 then ''Complete''
							when max(wi.TestStatusStage2)  = 5 then ''Testing''
							when max(wi.TestStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.TestStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.TestStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.TestStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DeployStatusStage2) is not null then
							case when max(wi.DeployStatusStage2)  = 7 then ''NA''
							when max(wi.DeployStatusStage2)  = 6 then ''Complete''
							when max(wi.DeployStatusStage2)  = 5 then ''Testing''
							when max(wi.DeployStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DeployStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DeployStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DeployStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.ReviewStatusStage2) is not null then
							case when max(wi.ReviewStatusStage2)  = 7 then ''NA''
							when max(wi.ReviewStatusStage2)  = 6 then ''Complete''
							when max(wi.ReviewStatusStage2)  = 5 then ''Testing''
							when max(wi.ReviewStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.ReviewStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.ReviewStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.ReviewStatusStage2)  = 1 then ''Not Ready''
							else null end
						else ''N/A'' end as [Task.Workload.Release Status] ';
				end;

			set @sql_with = @sql_with + '
				from w_filtered_tasks wi ' +
				@sql_from + ' where not exists (select 1 from w_exclude_task where Excluded_WorkItemID = wi.WORKITEMID';

				if @sql_where_exclude != '' and charindex('WORKITEMID', upper(@sql_select)) = 0
					begin
						set @sql_with = @sql_with + '
							and ' + @sql_where_exclude;
					end;

				set @sql_with = @sql_with + ')';

				if @sql_where != ''
					begin
						set @sql_with = @sql_with + '
							and ' + @sql_where;
					end;

				if charindex('JOIN AORRELEASE ARL', upper(@sql_from)) > 0
					begin
						set @sql_with = @sql_with + '
							and (isnull(arl.[Current], 1) = 1 or (select max(convert(int, arl2.[Current])) from AORReleaseTask art2 join AORRelease arl2 on art2.AORReleaseID = arl2.AORReleaseID where art2.WORKITEMID = wi.WORKITEMID) = 0) ';
					end;
				if charindex('WORKITEMID', upper(@sql_group)) > 0 and charindex('STATUSID', upper(@sql_group)) > 0
					begin
						set @sql_with = @sql_with +
							' group by ' + @sql_group + ', wi.SR_Number)';
					end;
				else 
					begin
						set @sql_with = @sql_with +
							' group by ' + @sql_group + ')';
					end;

				set @sql_with = @sql_with + '
		,
		w_sub_task_rollup as (
			select' + @sql_select_sub;

			if charindex('WORKITEM_TASKID', upper(@sql_select_sub)) > 0 and charindex('STATUSID', upper(@sql_select_sub)) > 0 
				begin
					set @sql_with = @sql_with + ', (select count(wit2.SRNumber) from WORKITEM_TASK wit2 where wit.SRNumber = wit2.SRNumber) - (select count(wit2.SRNumber) from WORKITEM_TASK wit2 where wit.SRNumber = wit2.SRNumber and wit2.STATUSID = 10) as [Unclosed SR Tasks]';
				end;
			
			if charindex('WORKITEMID', upper(@sql_select_sub)) = 0
				begin
					set @sql_with = @sql_with + ', ' + @sql_rollups_sub + ' isnull(sum(1), 0) as Total_Sub_Tasks';
				end;

			if charindex('WORKLOAD PRIORITY', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with + ', isnull(sum(case when wit.AssignedToRankID = 27 then 1 else 0 end), 0) as [1], isnull(sum(case when wit.AssignedToRankID = 28 then 1 else 0 end), 0) as [2], isnull(sum(case when wit.AssignedToRankID = 38 then 1 else 0 end), 0) as [3], isnull(sum(case when wit.AssignedToRankID = 29 then 1 else 0 end), 0) as [4], isnull(sum(case when wit.AssignedToRankID = 30 then 1 else 0 end), 0) as [5+], isnull(sum(case when wit.AssignedToRankID = 31 then 1 else 0 end), 0) as [6]';
				end;

			if charindex('TASK.WORKLOAD.RELEASE STATUS', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with +
					',case when max(wit.StatusStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.StatusStage), -1) and st.StatusType = ''Work'')
						else ''N/A'' end  + ''.'' +
						case when max(wit.PlanningStatusStage) is not null then
							case when max(wit.PlanningStatusStage)  = 7 then ''NA''
							when max(wit.PlanningStatusStage)  = 6 then ''Complete''
							when max(wit.PlanningStatusStage)  = 5 then ''Testing''
							when max(wit.PlanningStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.PlanningStatusStage)  = 3 then ''Progressing/In Work''
							when max(wit.PlanningStatusStage)  = 2 then ''Ready for Work''
							when max(wit.PlanningStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wit.DesignStatusStage) is not null then
							case when max(wit.DesignStatusStage)  = 7 then ''NA''
							when max(wit.DesignStatusStage)  = 6 then ''Complete''
							when max(wit.DesignStatusStage)  = 5 then ''Testing''
							when max(wit.DesignStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.DesignStatusStage)  = 3 then ''Progressing/In Work''
							when max(wit.DesignStatusStage)  = 2 then ''Ready for Work''
							when max(wit.DesignStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wit.DevelopStatusStage) is not null then
							case when max(wit.DevelopStatusStage)  = 7 then ''NA''
							when max(wit.DevelopStatusStage)  = 6 then ''Complete''
							when max(wit.DevelopStatusStage)  = 5 then ''Testing''
							when max(wit.DevelopStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.DevelopStatusStage)  = 3 then ''Progressing/In Work''
							when max(wit.DevelopStatusStage)  = 2 then ''Ready for Work''
							when max(wit.DevelopStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wit.TestStatusStage) is not null then
							case when max(wit.TestStatusStage)  = 7 then ''NA''
							when max(wit.TestStatusStage)  = 6 then ''Complete''
							when max(wit.TestStatusStage)  = 5 then ''Testing''
							when max(wit.TestStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.TestStatusStage)  = 3 then ''Progressing/In Work''
							when max(wit.TestStatusStage)  = 2 then ''Ready for Work''
							when max(wit.TestStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wit.DeployStatusStage) is not null then
							case when max(wit.DeployStatusStage)  = 7 then ''NA''
							when max(wit.DeployStatusStage)  = 6 then ''Complete''
							when max(wit.DeployStatusStage)  = 5 then ''Testing''
							when max(wit.DeployStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.DeployStatusStage)  = 3 then ''Progressing/In Work''
							when max(wit.DeployStatusStage)  = 2 then ''Ready for Work''
							when max(wit.DeployStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wit.ReviewStatusStage) is not null then
							case when max(wit.ReviewStatusStage)  = 7 then ''NA''
							when max(wit.ReviewStatusStage)  = 6 then ''Complete''
							when max(wit.ReviewStatusStage)  = 5 then ''Testing''
							when max(wit.ReviewStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.ReviewStatusStage)  = 3 then ''Progressing/In Work''
							when max(wit.ReviewStatusStage)  = 2 then ''Ready for Work''
							when max(wit.ReviewStatusStage)  = 1 then ''Not Ready''
							else null end
						else ''N/A'' end + ''.'' +
						';

						set @sql_with = @sql_with +
						' case when max(wit.PlanningStatusStage2) is not null then
							case when max(wit.PlanningStatusStage2)  = 7 then ''NA''
							when max(wit.PlanningStatusStage2)  = 6 then ''Complete''
							when max(wit.PlanningStatusStage2)  = 5 then ''Testing''
							when max(wit.PlanningStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.PlanningStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wit.PlanningStatusStage2)  = 2 then ''Ready for Work''
							when max(wit.PlanningStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wit.DesignStatusStage2) is not null then
							case when max(wit.DesignStatusStage2)  = 7 then ''NA''
							when max(wit.DesignStatusStage2)  = 6 then ''Complete''
							when max(wit.DesignStatusStage2)  = 5 then ''Testing''
							when max(wit.DesignStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.DesignStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wit.DesignStatusStage2)  = 2 then ''Ready for Work''
							when max(wit.DesignStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wit.DevelopStatusStage2) is not null then
							case when max(wit.DevelopStatusStage2)  = 7 then ''NA''
							when max(wit.DevelopStatusStage2)  = 6 then ''Complete''
							when max(wit.DevelopStatusStage2)  = 5 then ''Testing''
							when max(wit.DevelopStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.DevelopStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wit.DevelopStatusStage2)  = 2 then ''Ready for Work''
							when max(wit.DevelopStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wit.TestStatusStage2) is not null then
							case when max(wit.TestStatusStage2)  = 7 then ''NA''
							when max(wit.TestStatusStage2)  = 6 then ''Complete''
							when max(wit.TestStatusStage2)  = 5 then ''Testing''
							when max(wit.TestStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.TestStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wit.TestStatusStage2)  = 2 then ''Ready for Work''
							when max(wit.TestStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wit.DeployStatusStage2) is not null then
							case when max(wit.DeployStatusStage2)  = 7 then ''NA''
							when max(wit.DeployStatusStage2)  = 6 then ''Complete''
							when max(wit.DeployStatusStage2)  = 5 then ''Testing''
							when max(wit.DeployStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.DeployStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wit.DeployStatusStage2)  = 2 then ''Ready for Work''
							when max(wit.DeployStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wit.ReviewStatusStage2) is not null then
							case when max(wit.ReviewStatusStage2)  = 7 then ''NA''
							when max(wit.ReviewStatusStage2)  = 6 then ''Complete''
							when max(wit.ReviewStatusStage2)  = 5 then ''Testing''
							when max(wit.ReviewStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wit.ReviewStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wit.ReviewStatusStage2)  = 2 then ''Ready for Work''
							when max(wit.ReviewStatusStage2)  = 1 then ''Not Ready''
							else null end
						else ''N/A'' end as [Task.Workload.Release Status] ';
				end;

			set @sql_with = @sql_with + '
				from WORKITEM wi
				 join w_filtered_sub_tasks wit
				on wi.WORKITEMID = wit.WORKITEMID ' +
				@sql_from_sub;

				if @sql_where_sub != ''
					begin
						set @sql_with = @sql_with + '
							where ' + @sql_where_sub;
					end;

				if charindex('JOIN AORRELEASE ARL', upper(@sql_from_sub)) > 0
					begin
						set @sql_with = @sql_with + case when @sql_where_sub != '' then ' and' else ' where' end + '
							(isnull(arl.[Current], 1) = 1 or (select max(convert(int, arl2.[Current])) from AORReleaseTask art2 join AORRelease arl2 on art2.AORReleaseID = arl2.AORReleaseID where art2.WORKITEMID = wi.WORKITEMID) = 0) ';
					end;

				if charindex('WORKITEM_TASKID', upper(@sql_group_sub)) > 0 and charindex('STATUSID', upper(@sql_group_sub)) > 0
					begin
						set @sql_with = @sql_with +
							' group by ' + @sql_group_sub + ', wit.SRNumber)';
					end;
				else 
					begin
						set @sql_with = @sql_with +
							' group by ' + @sql_group_sub + ')';
					end;

		if charindex('WORKITEMID', upper(@sql_select_sub)) = 0 and charindex('Affiliated', upper(@sql_select)) > 0
				begin

				set @sql_with = @sql_with + '
				,
				w_task_rollup_Assigned as (
					select wi.ASSIGNEDRESOURCEID
					 ';

					set @sql_with = @sql_with + ', ' + @sql_rollups + ' isnull(sum(1), 0) as Total_Tasks';

				if charindex('WORKLOAD PRIORITY', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with + ', isnull(sum(case when wi.AssignedToRankID = 27 then 1 else 0 end), 0) as [1], isnull(sum(case when wi.AssignedToRankID = 28 then 1 else 0 end), 0) as [2], isnull(sum(case when wi.AssignedToRankID = 38 then 1 else 0 end), 0) as [3], isnull(sum(case when wi.AssignedToRankID = 29 then 1 else 0 end), 0) as [4], isnull(sum(case when wi.AssignedToRankID = 30 then 1 else 0 end), 0) as [5+], isnull(sum(case when wi.AssignedToRankID = 31 then 1 else 0 end), 0) as [6]';
				end;

				if charindex('TASK.WORKLOAD.RELEASE STATUS', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with +
					',case when max(wi.StatusStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.StatusStage), -1) and st.StatusType = ''Work'')
						else ''N/A'' end  + ''.'' +
						case when max(wi.PlanningStatusStage) is not null then
							case when max(wi.PlanningStatusStage)  = 7 then ''NA''
							when max(wi.PlanningStatusStage)  = 6 then ''Complete''
							when max(wi.PlanningStatusStage)  = 5 then ''Testing''
							when max(wi.PlanningStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.PlanningStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.PlanningStatusStage)  = 2 then ''Ready for Work''
							when max(wi.PlanningStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DesignStatusStage) is not null then
							case when max(wi.DesignStatusStage)  = 7 then ''NA''
							when max(wi.DesignStatusStage)  = 6 then ''Complete''
							when max(wi.DesignStatusStage)  = 5 then ''Testing''
							when max(wi.DesignStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DesignStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DesignStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DesignStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DevelopStatusStage) is not null then
							case when max(wi.DevelopStatusStage)  = 7 then ''NA''
							when max(wi.DevelopStatusStage)  = 6 then ''Complete''
							when max(wi.DevelopStatusStage)  = 5 then ''Testing''
							when max(wi.DevelopStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DevelopStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DevelopStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DevelopStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.TestStatusStage) is not null then
							case when max(wi.TestStatusStage)  = 7 then ''NA''
							when max(wi.TestStatusStage)  = 6 then ''Complete''
							when max(wi.TestStatusStage)  = 5 then ''Testing''
							when max(wi.TestStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.TestStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.TestStatusStage)  = 2 then ''Ready for Work''
							when max(wi.TestStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DeployStatusStage) is not null then
							case when max(wi.DeployStatusStage)  = 7 then ''NA''
							when max(wi.DeployStatusStage)  = 6 then ''Complete''
							when max(wi.DeployStatusStage)  = 5 then ''Testing''
							when max(wi.DeployStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DeployStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DeployStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DeployStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.ReviewStatusStage) is not null then
							case when max(wi.ReviewStatusStage)  = 7 then ''NA''
							when max(wi.ReviewStatusStage)  = 6 then ''Complete''
							when max(wi.ReviewStatusStage)  = 5 then ''Testing''
							when max(wi.ReviewStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.ReviewStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.ReviewStatusStage)  = 2 then ''Ready for Work''
							when max(wi.ReviewStatusStage)  = 1 then ''Not Ready''
							else null end
						else ''N/A'' end + ''.'' +
						';

						set @sql_with = @sql_with +
						' case when max(wi.PlanningStatusStage2) is not null then
							case when max(wi.PlanningStatusStage2)  = 7 then ''NA''
							when max(wi.PlanningStatusStage2)  = 6 then ''Complete''
							when max(wi.PlanningStatusStage2)  = 5 then ''Testing''
							when max(wi.PlanningStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.PlanningStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.PlanningStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.PlanningStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DesignStatusStage2) is not null then
							case when max(wi.DesignStatusStage2)  = 7 then ''NA''
							when max(wi.DesignStatusStage2)  = 6 then ''Complete''
							when max(wi.DesignStatusStage2)  = 5 then ''Testing''
							when max(wi.DesignStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DesignStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DesignStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DesignStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DevelopStatusStage2) is not null then
							case when max(wi.DevelopStatusStage2)  = 7 then ''NA''
							when max(wi.DevelopStatusStage2)  = 6 then ''Complete''
							when max(wi.DevelopStatusStage2)  = 5 then ''Testing''
							when max(wi.DevelopStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DevelopStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DevelopStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DevelopStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.TestStatusStage2) is not null then
							case when max(wi.TestStatusStage2)  = 7 then ''NA''
							when max(wi.TestStatusStage2)  = 6 then ''Complete''
							when max(wi.TestStatusStage2)  = 5 then ''Testing''
							when max(wi.TestStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.TestStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.TestStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.TestStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DeployStatusStage2) is not null then
							case when max(wi.DeployStatusStage2)  = 7 then ''NA''
							when max(wi.DeployStatusStage2)  = 6 then ''Complete''
							when max(wi.DeployStatusStage2)  = 5 then ''Testing''
							when max(wi.DeployStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DeployStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DeployStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DeployStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.ReviewStatusStage2) is not null then
							case when max(wi.ReviewStatusStage2)  = 7 then ''NA''
							when max(wi.ReviewStatusStage2)  = 6 then ''Complete''
							when max(wi.ReviewStatusStage2)  = 5 then ''Testing''
							when max(wi.ReviewStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.ReviewStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.ReviewStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.ReviewStatusStage2)  = 1 then ''Not Ready''
							else null end
						else ''N/A'' end as [Task.Workload.Release Status] ';
				end;

				set @sql_with = @sql_with + '
				from w_filtered_tasks wi ' +
				@sql_from + ' and isnull(wi.ASSIGNEDRESOURCEID, 0) = isnull(aff.WTS_RESOURCEID, 0)';

				if @sql_where != ''
					begin
						set @sql_with = @sql_with + '
							and ' + @sql_where;
					end;

				if charindex('JOIN AORRELEASE ARL', upper(@sql_from)) > 0
					begin
						set @sql_with = @sql_with + '
							and (isnull(arl.[Current], 1) = 1 or (select max(convert(int, arl2.[Current])) from AORReleaseTask art2 join AORRelease arl2 on art2.AORReleaseID = arl2.AORReleaseID where art2.WORKITEMID = wi.WORKITEMID) = 0) ';
					end;

				set @sql_with = @sql_with + '
					group by wi.ASSIGNEDRESOURCEID
				),
				w_sub_task_rollup_Assigned as (
					select wit.ASSIGNEDRESOURCEID
					 ';

				begin
					set @sql_with = @sql_with + ', ' + @sql_rollups_sub + ' isnull(sum(1), 0) as Total_Sub_Tasks';
				end;

				if charindex('WORKLOAD PRIORITY', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with + ', isnull(sum(case when wit.AssignedToRankID = 27 then 1 else 0 end), 0) as [1], isnull(sum(case when wit.AssignedToRankID = 28 then 1 else 0 end), 0) as [2], isnull(sum(case when wit.AssignedToRankID = 38 then 1 else 0 end), 0) as [3], isnull(sum(case when wit.AssignedToRankID = 29 then 1 else 0 end), 0) as [4], isnull(sum(case when wit.AssignedToRankID = 30 then 1 else 0 end), 0) as [5+], isnull(sum(case when wit.AssignedToRankID = 31 then 1 else 0 end), 0) as [6]';
				end;

				if charindex('TASK.WORKLOAD.RELEASE STATUS', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with +
					',case when max(wi.StatusStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.StatusStage), -1) and st.StatusType = ''Work'')
						else ''N/A'' end  + ''.'' +
						case when max(wi.PlanningStatusStage) is not null then
							case when max(wi.PlanningStatusStage)  = 7 then ''NA''
							when max(wi.PlanningStatusStage)  = 6 then ''Complete''
							when max(wi.PlanningStatusStage)  = 5 then ''Testing''
							when max(wi.PlanningStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.PlanningStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.PlanningStatusStage)  = 2 then ''Ready for Work''
							when max(wi.PlanningStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DesignStatusStage) is not null then
							case when max(wi.DesignStatusStage)  = 7 then ''NA''
							when max(wi.DesignStatusStage)  = 6 then ''Complete''
							when max(wi.DesignStatusStage)  = 5 then ''Testing''
							when max(wi.DesignStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DesignStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DesignStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DesignStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DevelopStatusStage) is not null then
							case when max(wi.DevelopStatusStage)  = 7 then ''NA''
							when max(wi.DevelopStatusStage)  = 6 then ''Complete''
							when max(wi.DevelopStatusStage)  = 5 then ''Testing''
							when max(wi.DevelopStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DevelopStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DevelopStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DevelopStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.TestStatusStage) is not null then
							case when max(wi.TestStatusStage)  = 7 then ''NA''
							when max(wi.TestStatusStage)  = 6 then ''Complete''
							when max(wi.TestStatusStage)  = 5 then ''Testing''
							when max(wi.TestStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.TestStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.TestStatusStage)  = 2 then ''Ready for Work''
							when max(wi.TestStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.DeployStatusStage) is not null then
							case when max(wi.DeployStatusStage)  = 7 then ''NA''
							when max(wi.DeployStatusStage)  = 6 then ''Complete''
							when max(wi.DeployStatusStage)  = 5 then ''Testing''
							when max(wi.DeployStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DeployStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.DeployStatusStage)  = 2 then ''Ready for Work''
							when max(wi.DeployStatusStage)  = 1 then ''Not Ready''
							else null end
						when max(wi.ReviewStatusStage) is not null then
							case when max(wi.ReviewStatusStage)  = 7 then ''NA''
							when max(wi.ReviewStatusStage)  = 6 then ''Complete''
							when max(wi.ReviewStatusStage)  = 5 then ''Testing''
							when max(wi.ReviewStatusStage)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.ReviewStatusStage)  = 3 then ''Progressing/In Work''
							when max(wi.ReviewStatusStage)  = 2 then ''Ready for Work''
							when max(wi.ReviewStatusStage)  = 1 then ''Not Ready''
							else null end
						else ''N/A'' end + ''.'' +
						';

						set @sql_with = @sql_with +
						' case when max(wi.PlanningStatusStage2) is not null then
							case when max(wi.PlanningStatusStage2)  = 7 then ''NA''
							when max(wi.PlanningStatusStage2)  = 6 then ''Complete''
							when max(wi.PlanningStatusStage2)  = 5 then ''Testing''
							when max(wi.PlanningStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.PlanningStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.PlanningStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.PlanningStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DesignStatusStage2) is not null then
							case when max(wi.DesignStatusStage2)  = 7 then ''NA''
							when max(wi.DesignStatusStage2)  = 6 then ''Complete''
							when max(wi.DesignStatusStage2)  = 5 then ''Testing''
							when max(wi.DesignStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DesignStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DesignStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DesignStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DevelopStatusStage2) is not null then
							case when max(wi.DevelopStatusStage2)  = 7 then ''NA''
							when max(wi.DevelopStatusStage2)  = 6 then ''Complete''
							when max(wi.DevelopStatusStage2)  = 5 then ''Testing''
							when max(wi.DevelopStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DevelopStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DevelopStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DevelopStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.TestStatusStage2) is not null then
							case when max(wi.TestStatusStage2)  = 7 then ''NA''
							when max(wi.TestStatusStage2)  = 6 then ''Complete''
							when max(wi.TestStatusStage2)  = 5 then ''Testing''
							when max(wi.TestStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.TestStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.TestStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.TestStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.DeployStatusStage2) is not null then
							case when max(wi.DeployStatusStage2)  = 7 then ''NA''
							when max(wi.DeployStatusStage2)  = 6 then ''Complete''
							when max(wi.DeployStatusStage2)  = 5 then ''Testing''
							when max(wi.DeployStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.DeployStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.DeployStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.DeployStatusStage2)  = 1 then ''Not Ready''
							else null end
						when max(wi.ReviewStatusStage2) is not null then
							case when max(wi.ReviewStatusStage2)  = 7 then ''NA''
							when max(wi.ReviewStatusStage2)  = 6 then ''Complete''
							when max(wi.ReviewStatusStage2)  = 5 then ''Testing''
							when max(wi.ReviewStatusStage2)  = 4 then ''Progressing/In Work (Healthy Progress)''
							when max(wi.ReviewStatusStage2)  = 3 then ''Progressing/In Work''
							when max(wi.ReviewStatusStage2)  = 2 then ''Ready for Work''
							when max(wi.ReviewStatusStage2)  = 1 then ''Not Ready''
							else null end
						else ''N/A'' end as [Task.Workload.Release Status] ';
				end;

			set @sql_with = @sql_with + '
				from WORKITEM wi
				full join w_filtered_sub_tasks wit
				on wi.WORKITEMID = wit.WORKITEMID ' +
				@sql_from_sub;

				if @sql_where_sub != ''
					begin
						set @sql_with = @sql_with + '
							where ' + @sql_where_sub;
					end;

				if charindex('JOIN AORRELEASE ARL', upper(@sql_from_sub)) > 0
					begin
						set @sql_with = @sql_with + case when @sql_where_sub != '' then ' and' else ' where' end + '
							(isnull(arl.[Current], 1) = 1 or (select max(convert(int, arl2.[Current])) from AORReleaseTask art2 join AORRelease arl2 on art2.AORReleaseID = arl2.AORReleaseID where art2.WORKITEMID = wi.WORKITEMID) = 0) ';
					end;

				set @sql_with = @sql_with + '
				and wit.ASSIGNEDRESOURCEID = aff.WTS_RESOURCEID
					group by wit.ASSIGNEDRESOURCEID
				)';

				end;

			if charindex('RESOURCE COUNT (T.BA.PA.CT)', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with + '
					,
					w_rc_sub as (
						select distinct
						wi.WORKITEMID
						,wi.ASSIGNEDRESOURCEID
						from WORKITEM wi
						join WORKITEM_TASK wit
						on wi.WORKITEMID = wit.WORKITEMID  and isnull(wit.[StatusID], 0) in (' + @QFStatus + ')
						 join [STATUS] s
						on wi.STATUSID = s.STATUSID and isnull(s.[StatusID], 0) in (' + @QFStatus + ')
						where (wit.ASSIGNEDRESOURCEID IN (' + @QFAffiliated +  ')
							or exists (
								select 1
								from #AffiliatedResourceTeamUser artu
								join WorkType_WTS_RESOURCE rgr
								on artu.ResourceID = rgr.WTS_RESOURCEID
								where artu.TeamResourceID = wit.ASSIGNEDRESOURCEID
								and rgr.WorkTypeID = wi.WorkTypeID
							)
						)
						UNION
						select distinct wi.WORKITEMID
						,wi.ASSIGNEDRESOURCEID
						from WORKITEM wi
						 join [STATUS] s
						on wi.STATUSID = s.STATUSID and isnull(s.[StatusID], 0) in (' + @QFStatus + ')
						where (wi.ASSIGNEDRESOURCEID IN (' + @QFAffiliated +  ')
							or exists (
								select 1
								from #AffiliatedResourceTeamUser artu
								join WorkType_WTS_RESOURCE rgr
								on artu.ResourceID = rgr.WTS_RESOURCEID
								where artu.TeamResourceID = wi.ASSIGNEDRESOURCEID
								and rgr.WorkTypeID = wi.WorkTypeID
							)
						)
						UNION
						select distinct wit.WORKITEMID
						,wit.ASSIGNEDRESOURCEID
						from WORKITEM_TASK wit
						join WORKITEM wi
						on wit.WORKITEMID = wi.WORKITEMID
						where isnull(wit.[StatusID], 0) in (' + @QFStatus + ')
						and (wit.ASSIGNEDRESOURCEID IN (' + @QFAffiliated +  ')
							or exists (
								select 1
								from #AffiliatedResourceTeamUser artu
								join WorkType_WTS_RESOURCE rgr
								on artu.ResourceID = rgr.WTS_RESOURCEID
								where artu.TeamResourceID = wit.ASSIGNEDRESOURCEID
								and rgr.WorkTypeID = wi.WorkTypeID
							)
						)
					)
					,w_RC_TOTALS as (
						SELECT ' + @sql_select + '
						,isnull(convert(nvarchar(10),  isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 1 then wrta.WTS_RESOURCEID  else null end), 0)
						  + isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 2 then wrta.WTS_RESOURCEID  else null end), 0)
						  + isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 3 then wrta.WTS_RESOURCEID  else null end), 0)) + ''.'' +
						  convert(nvarchar(10),  isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 1 then wrta.WTS_RESOURCEID  else null end), 0)) + ''.'' +
						  convert(nvarchar(10),  isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 2 then wrta.WTS_RESOURCEID  else null end), 0)) + ''.'' +
						  convert(nvarchar(10),  isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 3 then wrta.WTS_RESOURCEID  else null end), 0)), ''0.0.0.0'') as [Resource Count (T.BA.PA.CT)]
						from w_filtered_tasks wi
						' + @sql_from + '
						left join w_rc_sub rcs on wi.WORKITEMID = rcs.WORKITEMID
					   left join WTS_RESOURCE wrta on rcs.ASSIGNEDRESOURCEID = wrta.WTS_RESOURCEID
					   where isnull(wi.[StatusID], 0) in (' + @QFStatus + ')
					   ' ;

				if @sql_where != ''
					begin
						set @sql_with = @sql_with + '
							and ' + @sql_where;
					end;

				if charindex('JOIN AORRELEASE ARL', upper(@sql_from)) > 0
					begin
						set @sql_with = @sql_with + '
							and (isnull(arl.[Current], 1) = 1 or (select max(convert(int, arl2.[Current])) from AORReleaseTask art2 join AORRelease arl2 on art2.AORReleaseID = arl2.AORReleaseID where art2.WORKITEMID = wi.WORKITEMID) = 0) ';
					end;

					set @sql_with = @sql_with +
						' group by ' + @sql_group + '
					)';
				end;

			if charindex('RQMT RISK', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with + '
					,w_RQMT_Risk as (
						SELECT ' + @sql_select + '
							,convert(nvarchar(10), count(distinct rd.WTS_SYSTEMID)) + ''.'' + convert(nvarchar(10), count(distinct rd.WorkAreaID)) + '': '' +
							convert(nvarchar(10), count(distinct rd.WorkStoppage)) + ''.'' +
							convert(nvarchar(10), count(distinct rd.Deficient)) + ''.'' +
							convert(nvarchar(10), count(distinct rd.DNTNotTested)) + ''.'' +
							convert(nvarchar(10), count(distinct rd.RQMTSystemID)) + '' ('' +
							convert(nvarchar(10), count(distinct rd.RQMTSystemID) - (count(distinct rd.WorkStoppage) + count(distinct rd.Deficient) + count(distinct rd.DNTNotTested))) + '', '' +
							convert(nvarchar(10), round((convert(float, (count(distinct rd.RQMTSystemID) - (count(distinct rd.WorkStoppage) + count(distinct rd.Deficient) + count(distinct rd.DNTNotTested)))) / convert(float, nullif(count(distinct rd.RQMTSystemID), 0))) * 100, 0)) + ''%)'' as [RQMT Risk]
						from w_filtered_tasks wi
						 ' + @sql_from + '
						left join #RQMTData rd on wi.WTS_SYSTEMID = rd.WTS_SYSTEMID and wi.WorkAreaID = rd.WorkAreaID
					   where isnull(wi.[StatusID], 0) in (' + @QFStatus + ')
					   ' ;

				if @sql_where != ''
					begin
						set @sql_with = @sql_with + '
							and ' + @sql_where;
					end;

				if charindex('JOIN AORRELEASE ARL', upper(@sql_from)) > 0
					begin
						set @sql_with = @sql_with + '
							and (isnull(arl.[Current], 1) = 1 or (select max(convert(int, arl2.[Current])) from AORReleaseTask art2 join AORRelease arl2 on art2.AORReleaseID = arl2.AORReleaseID where art2.WORKITEMID = wi.WORKITEMID) = 0) ';
					end;

					set @sql_with = @sql_with +
						' group by ' + @sql_group + '
					)';
				end;

	set @sql = @sql +
		@sql_with + '
		select null AS ROW_ID, null as X, null as Y,' + @sql_select_level;

		if charindex('WORKITEMID', upper(@sql_select_level)) > 0 and charindex('STATUSID', upper(@sql_select_level)) > 0
			begin
				set @sql = @sql + ', isnull(trs.[Unclosed SR Tasks], tr.[Unclosed SR Tasks]) as [Unclosed SR Tasks]';
			end;

		if charindex('WORKITEMID', upper(@sql_select)) = 0 and charindex('Affiliated', upper(@sql_select)) = 0
			begin
				set @sql = @sql + ', ' + @sql_rollups_level + ' isnull(tr.Total_Tasks, 0) + isnull(trs.Total_Sub_Tasks, 0) as Total';
			end;

		if charindex('WORKITEMID', upper(@sql_select)) = 0 and charindex('Affiliated', upper(@sql_select)) > 0
			begin
				set @sql = @sql + ', ' + @sql_rollups_level_W_Assigned + ' convert(nvarchar(10),isnull(tra.Total_Tasks, 0) + isnull(trsa.Total_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10), isnull(tr.Total_Tasks, 0) + isnull(trs.Total_Sub_Tasks, 0)) as Total';

				set @sql_from_level_W_Assigned = ' full outer join w_task_rollup_Assigned tra
					on isnull(tr.Affiliated_ID, 0) = isnull(tra.ASSIGNEDRESOURCEID, 0)
					full outer join w_sub_task_rollup_Assigned trsa
					on isnull(tra.ASSIGNEDRESOURCEID, 0) = isnull(trsa.ASSIGNEDRESOURCEID, 0)
					and isnull(trs.Affiliated_ID, 0) = isnull(trsa.ASSIGNEDRESOURCEID, 0) ';
			end;

		if RTRIM(LTRIM(@sql_order_by_Aff)) != '' and @sql_order_by_Aff is not null
			begin
				set @sql_order_by = @sql_order_by_Aff + ', ' + @sql_order_by;
			end;

		set @sql = @sql + ', null as Z
			from w_task_rollup tr
			full outer join w_sub_task_rollup trs
			on ' + @sql_from_level + @sql_from_level_W_Assigned + @sql_from_level_RC + @sql_from_level_RQMTRisk + '
			order by ' + @sql_order_by;

	set @sql = @sql + '
	if object_id(''tempdb..#WorkloadPriority'') is not null
		begin
			drop table #WorkloadPriority;
		end;
	if object_id(''tempdb..#TaskAOR'') is not null
		begin
			drop table #TaskAOR;
		end;
	if object_id(''tempdb..#SubTaskAOR'') is not null
		begin
			drop table #SubTaskAOR;
		end;
	if object_id(''tempdb..#WorkTaskData'') is not null
		begin
			drop table #WorkTaskData;
		end;
	if object_id(''tempdb..#WTData'') is not null
		begin
			drop table #WTData;
		end;
	if object_id(''tempdb..#TaskData'') is not null
		begin
			drop table #TaskData;
		end;
	if object_id(''tempdb..#SubTaskData'') is not null
		begin
			drop table #SubTaskData;
		end;
	if object_id(''tempdb..#WorkPrioStatus'') is not null
		begin
			drop table #WorkPrioStatus;
		end;
	if object_id(''tempdb..#PD2TDRStatus'') is not null
		begin
			drop table #PD2TDRStatus;
		end;

	if object_id(''tempdb..#SessionData'') is not null
		begin
			drop table #SessionData;
			drop table #SessionDataSub;
		end;

	if object_id(''tempdb..#WorkTaskMilestones'') is not null
		begin
			drop table #WorkTaskMilestones;
			drop table #WorkTaskMilestonesSub;
		end;	
	drop table #AffiliatedResourceTeamUser;

	if object_id(''tempdb..#RQMTData'') is not null
		begin
			drop table #RQMTData;
		end;
	';
	
	if @Debug = 1
		begin
			select @sql;
		end;
	else
		begin
			execute sp_executesql @sql;
		end;

end;







GO

