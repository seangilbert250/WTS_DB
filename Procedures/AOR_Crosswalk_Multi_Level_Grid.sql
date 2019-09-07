USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AOR_Crosswalk_Multi_Level_Grid]    Script Date: 7/23/2018 12:17:48 PM ******/
DROP PROCEDURE [dbo].[AOR_Crosswalk_Multi_Level_Grid]
GO

/****** Object:  StoredProcedure [dbo].[AOR_Crosswalk_Multi_Level_Grid]    Script Date: 7/23/2018 12:17:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






 
CREATE procedure [dbo].[AOR_Crosswalk_Multi_Level_Grid]
	@SessionID nvarchar(100),
	@UserName nvarchar(100),
	@Level xml,
	@Filter xml,
	@QFRelease nvarchar(max),
	@QFAORType nvarchar(max),
	@QFVisibleToCustomer nvarchar(max),
	@QFContainsTasks nvarchar(max),
	@QFContract nvarchar(max),
	@QFTaskStatus nvarchar(max),
	@QFAORProductionStatus nvarchar(max),
	@QFShowArchiveAOR nvarchar(max), 
	@AORID_Filter_arr nvarchar(max),
	@GetColumns bit = 0,
	@Debug bit = 0
as
begin
	set nocount on;

	declare @date nvarchar(30);
	declare @sql nvarchar(max) = '';
	declare @sql_temp nvarchar(max) = '';
	declare @sql_temp_cleanup nvarchar(max) = '';
	declare @sql_with nvarchar(max) = '';
	declare @sql_select nvarchar(max) = '';
	declare @sql_from nvarchar(max) = '';
	declare @sql_where nvarchar(max) = '';
	declare @sql_group nvarchar(max) = '';
	declare @sql_group_sub nvarchar(max) = '';
	declare @sql_order_by nvarchar(max) = '';
	declare @sql_column_data nvarchar(max) = '';

	declare @sql_select_task nvarchar(max) = '';
	declare @sql_select_sub nvarchar(max) = '';
	declare @sql_from_task nvarchar(max) = '';
	declare @sql_from_sub nvarchar(max) = '';
	declare @sql_where_task nvarchar(max) = '';
	declare @sql_where_sub nvarchar(max) = '';
	declare @sql_where_sub_Parent nvarchar(max) = '';
	declare @sql_where_exclude nvarchar(max) = '';
	declare @sql_select_level nvarchar(max) = '';
	declare @sql_select_task_fields nvarchar(max) = '';
	declare @sql_join_task nvarchar(max) = '';
	
	declare @sql_from_level nvarchar(max) = '';
	declare @sql_from_main nvarchar(max) = '';
	declare @sql_col_group nvarchar(max) = '';
	declare @sql_col_group_filter nvarchar(max) = '';
	
	declare @sql_select_task_ids nvarchar(max) = '';
	declare @sql_select_sub_ids nvarchar(max) = '';
	declare @sql_from_level_ids nvarchar(max) = '';

	declare @sql_group_all nvarchar(max) = '';
	declare @sql_group_all1 nvarchar(max) = '';
	declare @sql_group_all2 nvarchar(max) = '';
	declare @alt int = 0;

	set @date = convert(nvarchar(30), getdate());

	with
	w_breakout as (
		select
			tbl.breakouts.value('column[1]', 'varchar(100)') as columnName,
			tbl.breakouts.value('sort[1]', 'varchar(100)') as columnSort
		from @Level.nodes('crosswalkparameters/level/breakout') as tbl(breakouts)
	),
	w_filter as (
		select
			tbl.filters.value('field[1]', 'varchar(100)') as fieldName,
			tbl.filters.value('id[1]', 'varchar(100)') as fieldID
		from @Filter.nodes('/filters/filter') as tbl(filters)
	)
	select @sql_select = ISNULL(stuff((select distinct ', ' + [dbo].[AOR_Get_Columns](columnName, 0, '', '', 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_from = ISNULL(stuff((select distinct tableName from (select ' ' + [dbo].[AOR_Get_Tables](columnName, 0) as tableName from w_breakout union select ' ' + [dbo].[AOR_Get_Tables](fieldName, 0) as tableName from w_filter) allTables for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_where = ISNULL(stuff((select distinct ' ' + [dbo].[AOR_Get_Columns](fieldName, 1, fieldID, '', 0) from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_order_by = ISNULL(stuff((select distinct ', ' + [dbo].[AOR_Get_Columns](columnName, 3, '', columnSort, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   
		   ,@sql_select_task = ISNULL(stuff((select ', ' + [dbo].[Get_Columns](columnName, 0, '', 0, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_select_sub = ISNULL(stuff((select ', ' + [dbo].[Get_Columns](columnName, 0, '', 1, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_from_task = ISNULL(stuff((select distinct tableName from (select ' ' + [dbo].[Get_Tables](columnName, 0, 0) as tableName from w_breakout union select ' ' + [dbo].[Get_Tables](fieldName, 0, 0) as tableName from w_filter) allTables for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_from_sub = ISNULL(stuff((select distinct tableName from (select ' ' + [dbo].[Get_Tables](columnName, 0, 1) as tableName from w_breakout union select ' ' + [dbo].[Get_Tables](fieldName, 0, 1) as tableName from w_filter) allTables for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_where_task = ISNULL(stuff((select distinct ' ' + [dbo].[Get_Columns](fieldName, 1, fieldID, 0, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_where_sub = ISNULL(stuff((select distinct ' ' + [dbo].[Get_Columns](fieldName, 1, fieldID, 1, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_where_sub_Parent = stuff((select distinct ' ' + [dbo].[Get_Columns](fieldName, 6, fieldID, 1, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '')
		   ,@sql_where_exclude = stuff((select distinct ' ' + [dbo].[Get_Tables](columnName, 2, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '')
		   ,@sql_group = stuff((select ', ' + [dbo].[Get_Columns](columnName, 2, '', 0, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '')
		   ,@sql_group_sub = stuff((select ', ' + [dbo].[Get_Columns](columnName, 2, '', 1, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '')
		   ,@sql_select_level = ISNULL(stuff((select ', ' + [dbo].[Get_Columns](columnName, 4, '', 1, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_from_level = ISNULL(stuff((select distinct ' ' + [dbo].[Get_Tables](columnName, 1, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_select_task_fields = ISNULL(stuff((select ', ' + [dbo].[Get_Columns](columnName, 7, '', 0, '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		   ,@sql_col_group = ISNULL(stuff((select ', ' + [dbo].[AOR_Get_Columns](columnName, 4, '', columnSort, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '') ,'')
		   ,@sql_col_group_filter = ISNULL(stuff((select ', ' + [dbo].[AOR_Get_Columns](fieldName, 4, fieldID, '', 0) from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')

		   --,@sql_join_task = ISNULL(stuff((select distinct ' ' + [dbo].[AOR_Get_Tables](columnName, 3) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
	--	   ,@sql_select_task_ids = ISNULL(stuff((select distinct ', ' + [dbo].[Get_Columns](fieldName, 0, '', 0, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		--   ,@sql_select_sub_ids = ISNULL(stuff((select distinct ', ' + [dbo].[Get_Columns](fieldName, 0, '', 1, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
		--   ,@sql_from_level_ids = ISNULL(stuff((select distinct ' ' + [dbo].[Get_Tables](fieldName, 1, 0) from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')

		   --,@sql_from_main = stuff((select distinct ' ' + [dbo].[AOR_Get_Tables](columnGroup, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '')
		   ;

		   set @sql_col_group = @sql_col_group + ',' + @sql_col_group_filter;

		if (charindex('W_WP_SUB', upper(@sql_from)) > 0 or charindex('W_RC_SUB', upper(@sql_from)) > 0 or charindex('W_CARRY_IN_OUT', upper(@sql_from)) > 0)
			begin
				if charindex('TASK', upper(@sql_col_group)) > 0 and charindex('SUB-TASK', upper(@sql_col_group)) = 0
					begin
						set @alt = 1;
					end;
				else if charindex('SUB-TASK', upper(@sql_col_group)) > 0
					begin
						set @alt = 2;
					end;

				with w_breakout as (
					select
						tbl.breakouts.value('column[1]', 'varchar(100)') as columnName,
						tbl.breakouts.value('sort[1]', 'varchar(100)') as columnSort
					from @Level.nodes('crosswalkparameters/level/breakout') as tbl(breakouts)
				),
				w_filter as (
					select
						tbl.filters.value('field[1]', 'varchar(100)') as fieldName,
						tbl.filters.value('id[1]', 'varchar(100)') as fieldID
					from @Filter.nodes('/filters/filter') as tbl(filters)
				)
				select @sql_select = ISNULL(stuff((select distinct ', ' + [dbo].[AOR_Get_Columns](columnName, 0, '', '', @alt) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'')
					   ,@sql_group_all1 = ISNULL(stuff((select ', ' + [dbo].[AOR_Get_Columns](columnName, 2, '', columnSort, 0) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '') ,'')
					   ,@sql_group_all2 = ISNULL(stuff((select ', ' + [dbo].[AOR_Get_Columns](fieldName, 2, fieldID, '', 0) from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),'');

				set @sql_group_all = @sql_group_all1 + ',';
				if (@sql_group_all = ',') set @sql_group_all = '';
				set @sql_group_all = @sql_group_all + @sql_group_all2;

				if right(@sql_group_all, 1) = ','
					begin
						set @sql_group_all = left(@sql_group_all, len(@sql_group_all) - 1)
					end;
			end;

		--todo: figure out how to handle when grouped with task/sub-task level
		if (charindex('W_CARRY_IN_OUT', upper(@sql_from)) > 0 and (charindex('TASK', upper(@sql_col_group)) > 0 or charindex('SUB-TASK', upper(@sql_col_group)) > 0 or charindex('W_WP_SUB', upper(@sql_from)) > 0 or charindex('W_RC_SUB', upper(@sql_from)) > 0))
			begin
				set @sql_select = replace(@sql_select, 'sum(cio.CarryInCount)', 'sum(distinct cio.CarryInCount)');
				set @sql_select = replace(@sql_select, 'sum(cio.CarryOutCount)', 'sum(distinct cio.CarryOutCount)');
				set @sql_select = replace(@sql_select, 'sum(cio.TotalCount)', 'sum(distinct cio.TotalCount)');
			end;

if @sql_select_task = '' 
	set @sql_select_task = @sql_select_task_ids;

if @sql_select_sub = '' 
	set @sql_select_sub = @sql_select_sub_ids;

if @sql_from_level = '' 
	set @sql_from_level = @sql_from_level_ids;

	if (charindex('TASK_NUMBER', upper(@sql_select_level)) > 0 and charindex('WI.WORKITEMID', upper(@sql_where_sub)) > 0)
			begin
				set @sql_where_sub = @sql_where_sub_Parent;
			end;

	if @sql_select = '' and @sql_select_task = '' and @sql_select_sub = '' and @GetColumns = 0 
		begin
			select 'No Data Found' as 'AOR';
			return;
		end;

	if @sql_select_task != ''
		begin
			if @sql_select = ''
				begin
					set @sql_select = @sql_select_task_fields;
				end;
			else
				begin
					if @sql_select_task_fields != ''
						begin
							set @sql_select = @sql_select + ',' + @sql_select_task_fields;
						end;
				end;
		end;

		if @sql_select_task_fields != '' and @sql_group_all != ''
		begin
			set @sql_select_task_fields = ',' +  @sql_select_task_fields
		end;

		if charindex('TASK.WORKLOAD.RELEASE STATUS', upper(@sql_select_level)) = 0 or @sql_join_task = ''
		begin
			if @sql_select_task != '' 
			begin
				set @sql_select_task = ' wi.WORKITEMID AS WITASKID,' +  @sql_select_task
			end;

			if @sql_select_sub != ''
			begin
				set @sql_select_sub = ' wit.WORKITEMID AS WITASKID,' +  @sql_select_sub
			end;
		
			if @sql_select_level != ''
			begin
				set @sql_select_level = ' isnull(trs.WITASKID, tr.WITASKID) as WITASKID,' +  @sql_select_level
			end;

			if @sql_from_level != ''
			begin
				set @sql_from_level = 'isnull(tr.WITASKID, 0) = isnull(trs.WITASKID, 0) and ' +  @sql_from_level
			end;

			if @sql_group != ''
			begin
				set @sql_group = ' wi.WORKITEMID, ' +  @sql_group
			end;

			if @sql_group_sub != ''
			begin
				set @sql_group_sub = ' wit.WORKITEMID, ' +  @sql_group_sub
			end;
		end;

		if @sql_join_task = ''
			begin
				set @sql_join_task = 'waft.WITASKID = wi.WORKITEMID and '
			end;

		if right(@sql_join_task, 4) = 'and '
		begin
			set @sql_join_task = left(@sql_join_task, len(@sql_join_task) - 4)
		end;

		
		if right(@sql_where_task, 4) = 'and '
		begin
			set @sql_where_task = left(@sql_where_task, len(@sql_where_task) - 4)
		end;

		if right(@sql_where_sub, 4) = 'and '
		begin
			set @sql_where_sub = left(@sql_where_sub, len(@sql_where_sub) - 4)
		end;

	if right(@sql_where_exclude, 4) = 'and '
		begin
			set @sql_where_exclude = left(@sql_where_exclude, len(@sql_where_exclude) - 4)
		end;

	if right(@sql_from_level, 4) = 'and ' and @sql_from_level != ''
		begin
			set @sql_from_level = 'and ' + left(@sql_from_level, len(@sql_from_level) - 4)
		end;

	if right(@sql_where, 4) = 'and '
		begin
			set @sql_where = left(@sql_where, len(@sql_where) - 4)
		end;

	if charindex('#AORACTUALSTART', upper(@sql_from)) > 0 or charindex('#AORACTUALEND', upper(@sql_from)) > 0
		begin
			set @sql_temp = @sql_temp + '
				--Each time a task was associated or disassociated with an AOR. If no history, but associated, get current association date.
				select art.AORReleaseID, art.WORKITEMID, isnull(rth.Associate, 1) as Associate, isnull(rth.CreatedDate, art.CreatedDate) as CreatedDate
				into #AORTaskData
				from AORReleaseTask art
				join AORRelease arl
				on art.AORReleaseID = arl.AORReleaseID
				left join AORReleaseTaskHistory rth
				on art.AORReleaseID = rth.AORReleaseID and art.WORKITEMID = rth.WORKITEMID
				where arl.AORWorkTypeID = 1;

				--All ranges of dates a task was associated with an AOR. (Dont want to include changes done when associated with another AOR, when task has been associated with multiple AORs)
				select a.AORReleaseID,
					a.WORKITEMID,
					a.CreatedDate as AssociatedDate,
					(select min(CreatedDate) from #AORTaskData where AORReleaseID = a.AORReleaseID and WORKITEMID = a.WORKITEMID and Associate = 0 and CreatedDate > a.CreatedDate) as DisassociatedDate,
					wi.AssignedToRankID
				into #AORTaskDateRange
				from #AORTaskData a
				join WORKITEM wi
				on a.WORKITEMID = wi.WORKITEMID
				where a.Associate = 1;

				select rst.AORReleaseID, rst.WORKITEMTASKID, isnull(sth.Associate, 1) as Associate, isnull(sth.CreatedDate, rst.CreatedDate) as CreatedDate
				into #AORSubTaskData
				from AORReleaseSubTask rst
				join AORRelease arl
				on rst.AORReleaseID = arl.AORReleaseID
				left join AORReleaseSubTaskHistory sth
				on rst.AORReleaseID = sth.AORReleaseID and rst.WORKITEMTASKID = sth.WORKITEM_TASKID
				where arl.AORWorkTypeID = 1;

				select a.AORReleaseID,
					a.WORKITEMTASKID,
					a.CreatedDate as AssociatedDate,
					(select min(CreatedDate) from #AORSubTaskData where AORReleaseID = a.AORReleaseID and WORKITEMTASKID = a.WORKITEMTASKID and Associate = 0 and CreatedDate > a.CreatedDate) as DisassociatedDate,
					wit.AssignedToRankID
				into #AORSubTaskDateRange
				from #AORSubTaskData a
				join WORKITEM_TASK wit
				on a.WORKITEMTASKID = wit.WORKITEM_TASKID
				where a.Associate = 1;
			';

			set @sql_temp_cleanup = @sql_temp_cleanup + '
				drop table #AORTaskData;
				drop table #AORTaskDateRange;
				drop table #AORSubTaskData;
				drop table #AORSubTaskDateRange;
			';
		end;

	if charindex('#AORACTUALSTART', upper(@sql_from)) > 0
		begin
			set @sql_temp = @sql_temp + '
				select a.AORReleaseID,
					convert(date, min(a.StartDate)) as ActualStartDate
				into #AORActualStart
				from (
					--Changed to current on AOR
					select tdr.AORReleaseID, wih.CREATEDDATE as StartDate
					from #AORTaskDateRange tdr
					join WorkItem_History wih
					on tdr.WORKITEMID = wih.WORKITEMID
					where wih.FieldChanged = ''Assigned To Rank''
					and wih.NewValue = ''2 - Current Workload''
					and wih.CREATEDDATE between tdr.AssociatedDate and isnull(tdr.DisassociatedDate, ''' + @date + ''')
					--Associated with AOR already set to current and no other changes to current
					union all
					select tdr.AORReleaseID, tdr.AssociatedDate as StartDate
					from #AORTaskDateRange tdr
					join WORKITEM wi
					on tdr.WORKITEMID = wi.WORKITEMID
					where wi.AssignedToRankID = 28
					and not exists (
						select 1
						from #AORTaskDateRange tdr2
						join WorkItem_History wih
						on tdr2.WORKITEMID = wih.WORKITEMID
						where wih.FieldChanged = ''Assigned To Rank''
						and wih.NewValue = ''2 - Current Workload''
						and wih.CREATEDDATE between tdr2.AssociatedDate and isnull(tdr2.DisassociatedDate, ''' + @date + ''')
						and tdr2.AORReleaseID = tdr.AORReleaseID
						and tdr2.WORKITEMID = wi.WORKITEMID
					)
					union all
					select sdr.AORReleaseID, wth.CREATEDDATE as StartDate
					from #AORSubTaskDateRange sdr
					join WORKITEM_TASK_HISTORY wth
					on sdr.WORKITEMTASKID = wth.WORKITEM_TASKID
					where wth.FieldChanged = ''Assigned To Rank''
					and wth.NewValue = ''2 - Current Workload''
					and wth.CREATEDDATE between sdr.AssociatedDate and isnull(sdr.DisassociatedDate, ''' + @date + ''')
					union all
					select sdr.AORReleaseID, sdr.AssociatedDate as StartDate
					from #AORSubTaskDateRange sdr
					join WORKITEM_TASK wit
					on sdr.WORKITEMTASKID = wit.WORKITEM_TASKID
					where wit.AssignedToRankID = 28
					and not exists (
						select 1
						from #AORSubTaskDateRange sdr2
						join WORKITEM_TASK_HISTORY wth
						on sdr2.WORKITEMTASKID = wth.WORKITEM_TASKID
						where wth.FieldChanged = ''Assigned To Rank''
						and wth.NewValue = ''2 - Current Workload''
						and wth.CREATEDDATE between sdr2.AssociatedDate and isnull(sdr2.DisassociatedDate, ''' + @date + ''')
						and sdr2.AORReleaseID = sdr.AORReleaseID
						and sdr2.WORKITEMTASKID = wit.WORKITEM_TASKID
					)
				) a
				group by a.AORReleaseID;
			';

			set @sql_temp_cleanup = @sql_temp_cleanup + '
				drop table #AORActualStart;
			';
		end;

	if charindex('#AORACTUALEND', upper(@sql_from)) > 0
		begin
			set @sql_temp = @sql_temp + '
				select a.AORReleaseID,
					convert(date, max(a.EndDate)) as ActualEndDate
				into #AORActualEnd
				from (
					--Changed to closed on AOR
					select tdr.AORReleaseID, wih.CREATEDDATE as EndDate
					from #AORTaskDateRange tdr
					join WorkItem_History wih
					on tdr.WORKITEMID = wih.WORKITEMID
					where wih.FieldChanged = ''Assigned To Rank''
					and wih.NewValue = ''6 - Closed Workload''
					and wih.CREATEDDATE between tdr.AssociatedDate and isnull(tdr.DisassociatedDate, ''' + @date + ''')
					--Associated with AOR already set to closed and no other changes to closed
					union all
					select tdr.AORReleaseID, tdr.AssociatedDate as EndDate
					from #AORTaskDateRange tdr
					join WORKITEM wi
					on tdr.WORKITEMID = wi.WORKITEMID
					where wi.AssignedToRankID = 31
					and not exists (
						select 1
						from #AORTaskDateRange tdr2
						join WorkItem_History wih
						on tdr2.WORKITEMID = wih.WORKITEMID
						where wih.FieldChanged = ''Assigned To Rank''
						and wih.NewValue = ''6 - Closed Workload''
						and wih.CREATEDDATE between tdr2.AssociatedDate and isnull(tdr2.DisassociatedDate, ''' + @date + ''')
						and tdr2.AORReleaseID = tdr.AORReleaseID
						and tdr2.WORKITEMID = wi.WORKITEMID
					)
					union all
					select sdr.AORReleaseID, wth.CREATEDDATE as EndDate
					from #AORSubTaskDateRange sdr
					join WORKITEM_TASK_HISTORY wth
					on sdr.WORKITEMTASKID = wth.WORKITEM_TASKID
					where wth.FieldChanged = ''Assigned To Rank''
					and wth.NewValue = ''6 - Closed Workload''
					and wth.CREATEDDATE between sdr.AssociatedDate and isnull(sdr.DisassociatedDate, ''' + @date + ''')
					union all
					select sdr.AORReleaseID, sdr.AssociatedDate as EndDate
					from #AORSubTaskDateRange sdr
					join WORKITEM_TASK wit
					on sdr.WORKITEMTASKID = wit.WORKITEM_TASKID
					where wit.AssignedToRankID = 31
					and not exists (
						select 1
						from #AORSubTaskDateRange sdr2
						join WORKITEM_TASK_HISTORY wth
						on sdr2.WORKITEMTASKID = wth.WORKITEM_TASKID
						where wth.FieldChanged = ''Assigned To Rank''
						and wth.NewValue = ''6 - Closed Workload''
						and wth.CREATEDDATE between sdr2.AssociatedDate and isnull(sdr2.DisassociatedDate, ''' + @date + ''')
						and sdr2.AORReleaseID = sdr.AORReleaseID
						and sdr2.WORKITEMTASKID = wit.WORKITEM_TASKID
					)
				) a
				where (select count(1) from #AORTaskDateRange where AORReleaseID = a.AORReleaseID and AssignedToRankID != 31) = 0
				and (select count(1) from #AORSubTaskDateRange where AORReleaseID = a.AORReleaseID and AssignedToRankID != 31) = 0
				group by a.AORReleaseID;
			';

			set @sql_temp_cleanup = @sql_temp_cleanup + '
				drop table #AORActualEnd;
			';
		end;

	if charindex('WORKTASKMILESTONES', upper(@sql_from_task)) > 0 or charindex('WORKTASKMILESTONES', upper(@sql_from_sub)) > 0
		begin
			set @sql_temp = @sql_temp + '
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

			set @sql_temp_cleanup = @sql_temp_cleanup + '
				drop table #WorkTaskMilestones;
				drop table #WorkTaskMilestonesSub;
			';
		end;

	if charindex('W_CARRY_IN_OUT', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_carry_in as (
					select art.AORReleaseID,
						count(1) as CarryInCount
					from AORReleaseTask art
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					where exists (
						select 1
						from AORReleaseTask
						where AORReleaseID = (select max(AORReleaseID) from AORRelease where AORID = arl.AORID and AORReleaseID < art.AORReleaseID)
						and WORKITEMID = art.WORKITEMID
					)
					group by art.AORReleaseID
				),
				w_carry_out as (
					select art.AORReleaseID,
						count(1) as CarryOutCount
					from AORReleaseTask art
					join WORKITEM wi
					on art.WORKITEMID = wi.WORKITEMID
					join [STATUS] s
					on wi.STATUSID = s.STATUSID
					where upper(s.[STATUS]) != ''CLOSED''
					group by art.AORReleaseID
				),
				w_carry_in_out as (
					select arl.AORReleaseID,
						isnull(wci.CarryInCount, 0) as CarryInCount,
						isnull(wco.CarryOutCount, 0) as CarryOutCount,
						count(art.WORKITEMID) as TotalCount
					from AORRelease arl
					left join w_carry_in wci
					on arl.AORReleaseID = wci.AORReleaseID
					left join w_carry_out wco
					on arl.AORReleaseID = wco.AORReleaseID
					left join AORReleaseTask art
					on arl.AORReleaseID = art.AORReleaseID
					group by arl.AORReleaseID,
						wci.CarryInCount,
						wco.CarryOutCount
				),';
		end;

	if charindex('W_LAST_MEETING', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_last_meeting as (
					select arl.AORID,
						max(ami.InstanceDate) as LastMeeting
					from AORMeetingInstance ami
					join AORMeetingAOR ama
					on (ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add and ama.AORMeetingInstanceID_Remove is null)
					join AORRelease arl
					on ama.AORReleaseID = arl.AORReleaseID
					where ami.InstanceDate < ''' + @date + '''
					group by arl.AORID
				),';
		end;

	if charindex('W_NEXT_MEETING', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_next_meeting as (
					select arl.AORID,
						min(ami.InstanceDate) as NextMeeting
					from AORMeetingInstance ami
					join AORMeetingAOR ama
					on (ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add and ama.AORMeetingInstanceID_Remove is null)
					join AORRelease arl
					on ama.AORReleaseID = arl.AORReleaseID
					where ami.InstanceDate > ''' + @date + '''
					group by arl.AORID
				),';
		end;

	if charindex('W_MEETING_COUNT', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_meeting_count as (
					select arl.AORID,
						count(distinct ami.AORMeetingID) as MeetingCount
					from AORMeetingInstance ami
					join AORMeetingAOR ama
					on (ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add and ama.AORMeetingInstanceID_Remove is null)
					join AORRelease arl
					on ama.AORReleaseID = arl.AORReleaseID
					group by arl.AORID
				),';
		end;

	if charindex('W_ATTACHMENT_COUNT', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_attachment_count as (
					select arl.AORReleaseID,
						count(distinct ara.AORReleaseAttachmentID) as AttachmentCount
					from AORReleaseAttachment ara
					join AORRelease arl
					on ara.AORReleaseID = arl.AORReleaseID
					group by arl.AORReleaseID
				),';
		end;

		if charindex('W_AFFILIATED', upper(@sql_from)) > 0 or charindex('W_AFFILIATED', upper(@sql_from_sub)) > 0
		begin
			set @sql_with = @sql_with + '
				w_aor as (
					select arr.WTS_RESOURCEID,
						art.WORKITEMID
					from AORReleaseTask art
					join AORReleaseResource arr
					on art.AORReleaseID = arr.AORReleaseID
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					where arl.[Current] = 1
				),
				w_system as (
					select wsy.BusWorkloadManagerID as WTS_RESOURCEID,
						wi.WORKITEMID
					from WTS_SYSTEM wsy
					join WORKITEM wi
					on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
					union all
					select wsy.DevWorkloadManagerID as WTS_RESOURCEID,
						wi.WORKITEMID
					from WTS_SYSTEM wsy
					join WORKITEM wi
					on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
					union all
					select wsr.WTS_RESOURCEID,
						wi.WORKITEMID
					from WTS_SYSTEM_RESOURCE wsr
					join WORKITEM wi
					on wsr.WTS_SYSTEMID = wi.WTS_SYSTEMID and wsr.ProductVersionID = wi.ProductVersionID
				),
				w_affiliated as (
					select distinct wi.WORKITEMID, wi.WTS_RESOURCEID, wir.USERNAME
					from (
						select wi.WORKITEMID, wi.ASSIGNEDRESOURCEID as WTS_RESOURCEID from WORKITEM wi 
						union all
						select wi.WORKITEMID, wi.PRIMARYRESOURCEID as WTS_RESOURCEID from WORKITEM wi 
						union all
						select aor.WORKITEMID, aor.WTS_RESOURCEID from w_aor aor join w_system wsy on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID 
					) wi
					join WTS_RESOURCE wir
					on wi.WTS_RESOURCEID = wir.WTS_RESOURCEID
				),
				w_affiliated_sub as (
					select distinct wit.WORKITEM_TASKID, wit.WTS_RESOURCEID, wir.USERNAME
					from (
						select wit.WORKITEM_TASKID, wit.ASSIGNEDRESOURCEID as WTS_RESOURCEID from WORKITEM_TASK wit 
						union all
						select wit.WORKITEM_TASKID, wit.PrimaryResourceID as WTS_RESOURCEID from WORKITEM_TASK wit 
						union all
						select wit.WORKITEM_TASKID, aor.WTS_RESOURCEID from w_aor aor join w_system wsy on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID join WORKITEM_TASK wit on aor.WORKITEMID = wit.WORKITEMID 
					) wit
					join WTS_RESOURCE wir
					on wit.WTS_RESOURCEID = wir.WTS_RESOURCEID
				),';
		end;

if @sql_select_task != '' or @sql_select_sub != '' 
begin
		set @sql_with = @sql_with + '
		w_TaskAOR_WorkType as (
			select wi.WORKITEMID,
				AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				wal.WorkloadAllocation,
				wal.WorkloadAllocationID,
				isnull(rta.CascadeAOR, 0) as CascadeAOR,
				isnull(awt.AORWorkTypeName, ''No AOR Type'') as AORType,
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
				';

			set @sql_with = @sql_with + '
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
			and (AOR.Archive = 0 or AOR.Archive = ' + @QFShowArchiveAOR + ')
		),
		';

			set @sql_with = @sql_with + '
		w_SubTaskAOR_WorkType as (
			select wi.WORKITEM_TASKID,
			AOR.AORID,
			arl.AORName,
			arl.AORReleaseID,
			wal.WorkloadAllocation,
			wal.WorkloadAllocationID,
			isnull(rta.CascadeAOR, 0) as CascadeAOR,
			isnull(awt.AORWorkTypeName, ''No AOR Type'') as AORType,
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
			';

			set @sql_with = @sql_with + '
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseSubTask rsta
			on arl.AORReleaseID = rsta.AORReleaseID
			join WORKITEM_TASK wi
			on rsta.WORKITEMTASKID = wi.WORKITEM_TASKID
			left join AORWorkType awt
			on arl.AORWorkTypeID = awt.AORWorkTypeID
			left join WorkloadAllocation wal
			on arl.WorkloadAllocationID = wal.WorkloadAllocationID
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
			and (AOR.Archive = 0 or AOR.Archive = ' + @QFShowArchiveAOR + ')
		),
		';

			set @sql_with = @sql_with + '
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
			tawt2.WorkloadAllocation,
			tawt2.WorkloadAllocationID,
			convert(int, rta.CascadeAOR) as CascadeAOR2,
			tawt2.AORType as AORType2,
			tawt2.InvestigationStage as InvestigationStage2,
			tawt2.TechnicalStage as TechnicalStage2,
			tawt2.CustomerDesignStage as CustomerDesignStage2,
			tawt2.CodingStage as CodingStage2,
			tawt2.InternalTestingStage as InternalTestingStage2,
			tawt2.CustomerValidationTestingStage as CustomerValidationTestingStage2,
			tawt2.AdoptionStage as AdoptionStage2
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
		';

			set @sql_with = @sql_with + '
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
			tawt2.WorkloadAllocation,
			tawt2.WorkloadAllocationID,
			convert(int, tawt2.CascadeAOR) as CascadeAOR2,
			tawt2.AORType as AORType2,
			tawt2.InvestigationStage as InvestigationStage2,
			tawt2.TechnicalStage as TechnicalStage2,
			tawt2.CustomerDesignStage as CustomerDesignStage2,
			tawt2.CodingStage as CodingStage2,
			tawt2.InternalTestingStage as InternalTestingStage2,
			tawt2.CustomerValidationTestingStage as CustomerValidationTestingStage2,
			tawt2.AdoptionStage as AdoptionStage2
			';

			set @sql_with = @sql_with + '
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
		),
		w_exclude_task as (
			select distinct wit.WORKITEMID as Excluded_WorkItemID,' + @sql_select_sub + '
			from w_filtered_tasks wi
			join w_filtered_sub_tasks wit
			on wi.WORKITEMID = wit.WORKITEMID and isnull(wi.[StatusID], 0) in (' + @QFTaskStatus + ') and isnull(wit.[StatusID], 0) in (' + @QFTaskStatus + ') ' +
			@sql_from_sub;

			if @sql_where_sub != ''
				begin
					set @sql_with = @sql_with + '
						where ' + @sql_where_sub;
				end;

			if (charindex('TASK_NUMBER', upper(@sql_select_level)) = 0 and charindex('PRIMARY TASK', upper(@sql_select_level)) > 0)
			begin
					set @sql_with = @sql_with + '
						and wit.WORKITEMID = 0 ';
					end;

	set @sql_with = @sql_with + '
		),
		w_task_rollup as (
			select distinct ' + @sql_select_task;
			
			if charindex('TASK.WORKLOAD.RELEASE STATUS', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with + 
					',case when max(wi.StatusStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.StatusStage), -1) and st.StatusType = ''Work'')
						else ''N/A'' end  + ''.'' +
						case when max(wi.AdoptionStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.AdoptionStage), -1) and st.StatusType = ''Adopt'')
						when max(wi.CustomerValidationTestingStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.CustomerValidationTestingStage), -1) and st.StatusType = ''CVT'')
						when max(wi.InternalTestingStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.InternalTestingStage), -1) and st.StatusType = ''IT'')
						when max(wi.CodingStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.CodingStage), -1) and st.StatusType = ''C'')
						when max(wi.CustomerDesignStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.CustomerDesignStage), -1) and st.StatusType = ''CD'')
						when max(wi.TechnicalStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.TechnicalStage), -1) and st.StatusType = ''TD'')
						when max(wi.InvestigationStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.InvestigationStage), -1) and st.StatusType = ''Inv'')
						else ''N/A'' end + ''.'' + 
						case when max(wi.AdoptionStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.AdoptionStage2), -1) and st.StatusType = ''Adopt'')
						when max(wi.CustomerValidationTestingStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.CustomerValidationTestingStage2), -1) and st.StatusType = ''CVT'')
						when max(wi.InternalTestingStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.InternalTestingStage2), -1) and st.StatusType = ''IT'')
						when max(wi.CodingStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.CodingStage2), -1) and st.StatusType = ''C'')
						when max(wi.CustomerDesignStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.CustomerDesignStage2), -1) and st.StatusType = ''CD'')
						when max(wi.TechnicalStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.TechnicalStage2), -1) and st.StatusType = ''TD'')
						when max(wi.InvestigationStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wi.InvestigationStage2), -1) and st.StatusType = ''Inv'')
						else ''N/A'' end as [Task.Workload.Release Status] ';
				end;

			set @sql_with = @sql_with + '
				from w_filtered_tasks wi ' +
				@sql_from_task  
				+ ' where not exists (select 1 from w_exclude_task where Excluded_WorkItemID = wi.WORKITEMID';

				if @sql_where_exclude != '' and charindex('WORKITEM', upper(@sql_select_task)) = 0
					begin
						set @sql_with = @sql_with + '
							and ' + @sql_where_exclude;
					end;

				set @sql_with = @sql_with + ')';

				if @sql_where_task != ''
					begin
						set @sql_with = @sql_with + '
							and ' + @sql_where_task ;
					end;
					set @sql_with = @sql_with + '
					and isnull(wi.[StatusID], 0) in (' + @QFTaskStatus + ')  ';

				
				if @sql_group != ''
				begin
					set @sql_with = @sql_with + '
					group by ' + @sql_group;
					end;

	set @sql_with = @sql_with + '
		),
		w_sub_task_rollup as (
			select distinct ' + @sql_select_sub;

			if charindex('TASK.WORKLOAD.RELEASE STATUS', upper(@sql_select_level)) > 0
				begin
					set @sql_with = @sql_with + 
					',case when max(wit.StatusStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.StatusStage), -1) and st.StatusType = ''Work'')
						else ''N/A'' end  + ''.'' +
						case when max(wit.AdoptionStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.AdoptionStage), -1) and st.StatusType = ''Adopt'')
						when max(wit.CustomerValidationTestingStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.CustomerValidationTestingStage), -1) and st.StatusType = ''CVT'')
						when max(wit.InternalTestingStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.InternalTestingStage), -1) and st.StatusType = ''IT'')
						when max(wit.CodingStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.CodingStage), -1) and st.StatusType = ''C'')
						when max(wit.CustomerDesignStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.CustomerDesignStage), -1) and st.StatusType = ''CD'')
						when max(wit.TechnicalStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.TechnicalStage), -1) and st.StatusType = ''TD'')
						when max(wit.InvestigationStage) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.InvestigationStage), -1) and st.StatusType = ''Inv'')
						else ''N/A'' end + ''.'' + 
						case when max(wit.AdoptionStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.AdoptionStage2), -1) and st.StatusType = ''Adopt'')
						when max(wit.CustomerValidationTestingStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.CustomerValidationTestingStage2), -1) and st.StatusType = ''CVT'')
						when max(wit.InternalTestingStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.InternalTestingStage2), -1) and st.StatusType = ''IT'')
						when max(wit.CodingStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.CodingStage2), -1) and st.StatusType = ''C'')
						when max(wit.CustomerDesignStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.CustomerDesignStage2), -1) and st.StatusType = ''CD'')
						when max(wit.TechnicalStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.TechnicalStage2), -1) and st.StatusType = ''TD'')
						when max(wit.InvestigationStage2) is not null then (select s.[STATUS] from [STATUS] s left join StatusType st on s.StatusTypeID = st.StatusTypeID where isnull(s.SORT_ORDER, -1) = isnull(max(wit.InvestigationStage2), -1) and st.StatusType = ''Inv'')
						else ''N/A'' end as [Task.Workload.Release Status] ';
				end;

			set @sql_with = @sql_with + '
				from WORKITEM wi
				 join w_filtered_sub_tasks wit
				on wi.WORKITEMID = wit.WORKITEMID and isnull(wit.[StatusID], 0) in (' + @QFTaskStatus + ') ' +
				@sql_from_sub;

				if @sql_where_sub != ''
					begin
						set @sql_with = @sql_with + '
							where ' + @sql_where_sub;
					end;

			if (charindex('TASK_NUMBER', upper(@sql_select_level)) = 0 and charindex('PRIMARY TASK', upper(@sql_select_level)) > 0)
			begin
					set @sql_with = @sql_with + '
						and wit.WORKITEMID = 0 ';
					end;
					
					if @sql_group_sub != ''
				begin
					set @sql_with = @sql_with + '
					group by ' + @sql_group_sub;
					end;

		set @sql_with = @sql_with + '
		),
		w_all_filtered_task as (
		select ' + @sql_select_level + 
		' from  w_task_rollup tr 
			full outer join w_sub_task_rollup trs  
			on 1 = 1
			' + @sql_from_level + '),'
		;

		if charindex('TASK', upper(@sql_col_group)) > 0 or charindex('W_WP_SUB', upper(@sql_from)) > 0 or charindex('W_RC_SUB', upper(@sql_from)) > 0
			begin
				set @sql_from = @sql_from + '
					join w_all_filtered_task waft
					--on waft.WITASKID = wi.WORKITEMID 
					on ' + @sql_join_task + '
					'
					;
			end;
		
	end;

	if charindex('W_WP_SUB', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_all_subtask as (
					select wit.WORKITEMID as Excluded_WorkItemID
					,wit.STATUSID
					from WORKITEM wi
					join WORKITEM_TASK wit
					on wi.WORKITEMID = wit.WORKITEMID 
					where isnull(wit.[StatusID], 0) in (' + @QFTaskStatus + ')
					and isnull(wi.[StatusID], 0) in (' + @QFTaskStatus + ')
				),
				w_wp_sub as (
					select WORKITEMID,
						sum(case when AssignedToRankID = 27 then 1 else 0 end) as [1],
						sum(case when AssignedToRankID = 28 then 1 else 0 end) as [2],
						sum(case when AssignedToRankID = 38 then 1 else 0 end) as [3],
						sum(case when AssignedToRankID = 29 then 1 else 0 end) as [4],
						sum(case when AssignedToRankID = 30 then 1 else 0 end) as [5+],
						sum(case when AssignedToRankID = 31 then 1 else 0 end) as [6]
					from(
					select wit.WORKITEMID,wit.WORKITEM_TASKID,wit.AssignedToRankID 
					from WORKITEM wi
					join WORKITEM_TASK wit
					on wi.WORKITEMID = wit.WORKITEMID
					join [STATUS] s
					on wit.STATUSID = s.STATUSID
					where isnull(wit.[StatusID], 0) in (' + @QFTaskStatus + ') --upper(s.[STATUS]) != ''CLOSED''
					and isnull(wi.[StatusID], 0) in (' + @QFTaskStatus + ')
					UNION
					select wi.WORKITEMID,NULL,wi.AssignedToRankID
					from WORKITEM wi
					join [STATUS] s
					on wi.STATUSID = s.STATUSID 
					where not exists (select 1 from w_all_subtask where Excluded_WorkItemID = wi.WORKITEMID)
					--and upper(s.[STATUS]) != ''CLOSED''
					--and isnull(wi.[StatusID], 0) in (' + @QFTaskStatus + ')
					UNION
					select wi.WORKITEMID,NULL,wi.AssignedToRankID
					from WORKITEM wi
					join [STATUS] s
					on wi.STATUSID = s.STATUSID 
					 join WORKITEM_TASK wit 
					on  wi.WORKITEMID = wit.WORKITEMID
					 join [STATUS] swi
					on wit.STATUSID = swi.STATUSID 
					where not exists (select 1 from w_all_subtask wet join [STATUS] s on wet.STATUSID = s.STATUSID where Excluded_WorkItemID = wi.WORKITEMID /*and upper(s.[STATUS]) != ''CLOSED''*/) 
					--and upper(s.[STATUS]) != ''CLOSED''
					--and upper(swi.[STATUS]) = ''CLOSED''
					and isnull(wit.[StatusID], 0) in (' + @QFTaskStatus + ')
					and isnull(wi.[StatusID], 0) in (' + @QFTaskStatus + ')
					) a
					group by WORKITEMID
				),';
		end;

		if charindex('W_RC_SUB', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_rc_sub as (
					select distinct wi.WORKITEMID
					,wi.ASSIGNEDRESOURCEID
					from WORKITEM wi
					join [STATUS] s
					on wi.STATUSID = s.STATUSID and isnull(s.[StatusID], 0) in (' + @QFTaskStatus + ')
					UNION 
					select distinct wit.WORKITEMID
					,wit.ASSIGNEDRESOURCEID
					from WORKITEM_TASK wit
					where isnull(wit.[StatusID], 0) in (' + @QFTaskStatus + ')
				),';
		end;

		if charindex('SUB-TASK', upper(@sql_col_group)) > 0
		begin
			set @sql_with = @sql_with + '
			w_subTask as (
				select wit.* from
					WORKITEM_TASK wit
				   join [STATUS] sts on wit.STATUSID = sts.STATUSID 
				   and isnull(wit.[StatusID], 0) in (' + @QFTaskStatus + ')
				),';
		end;

	if @sql_with != ''
		begin
			set @sql_with = 'with ' + @sql_with;

			if right(@sql_with, 1) = ','
				begin
					set @sql_with = left(@sql_with, len(@sql_with) - 1)
				end;
		end;

	--if charindex('AOR', upper(@sql_col_group)) > 0
	--	begin
	--		set @sql_from_main = @sql_from_main + '
	--		left join AORReleaseCR arc
	--		on arc.AORReleaseID = arl.AORReleaseID
	--		left join AORCR acr
	--		on acr.CRID = arc.CRID '  
	--		;
	--	end;
	if charindex('CR', upper(@sql_col_group)) > 0
		begin
			if charindex('AOR', upper(@sql_col_group)) > 0 or charindex('SR', upper(@sql_col_group)) > 0 or charindex('TASK', upper(@sql_col_group)) > 0
				begin
					set @sql_from_main = @sql_from_main + '
					left join AORReleaseCR arc
					on arc.AORReleaseID = arl.AORReleaseID
					left join AORCR acr
					on acr.CRID = arc.CRID '  
					;
				end;
			else
				begin
					set @sql_from_main = @sql_from_main + '
					left join AORReleaseCR arc
					on arc.AORReleaseID = arl.AORReleaseID
					left join AORCR acr
					on acr.CRID = arc.CRID '  
					;
				end;
		end;
	if charindex('SR', upper(@sql_col_group)) > 0
		begin
			set @sql_from_main = '
			left join AORReleaseCR arc
			on arc.AORReleaseID = arl.AORReleaseID
			left join AORCR acr
			on acr.CRID = arc.CRID
			left join AORSR asr
			on acr.CRID = asr.CRID '  
			;
		end;
	if charindex('TASK', upper(@sql_col_group)) > 0 or charindex('W_WP_SUB', upper(@sql_from)) > 0 or charindex('W_RC_SUB', upper(@sql_from)) > 0
		begin
			set @sql_from_main = @sql_from_main + '
			left join WORKITEM wi
			on rta.WORKITEMID = wi.WORKITEMID
			left join [WTS_SYSTEM_CONTRACT] wsct
			on wi.[WTS_SYSTEMID] = wsct.[WTS_SYSTEMID]
			left join [CONTRACT] stc
			on wsct.[CONTRACTID] = stc.[CONTRACTID]
			 '  
			;
		end;
	if charindex('SUB-TASK', upper(@sql_col_group)) > 0
		begin
			set @sql_from_main = @sql_from_main + '
			left join w_subTask wit
			on wi.WORKITEMID = wit.WORKITEMID '  
			;
		end;

	set @sql =
		@sql_temp + 
		@sql_with + '
		select * from (select distinct null as X, ' + @sql_select;

		if charindex('CARRY IN', upper(@sql_select)) > 0 and charindex('CURRENT RELEASE', upper(@sql_select)) > 0
			begin
				set @sql = @sql + ', '''' as Release';
			end;

		if charindex('TIER', upper(@sql_select)) > 0 and charindex('RANK', upper(@sql_select)) > 0
			begin
				set @sql = @sql + ', '''' as [Tier Rank]';
			end;

		set @sql = @sql + ', null as Z, null as Y
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID 
			left join AORReleaseTask rta
			on arl.AORReleaseID = rta.AORReleaseID
			' + @sql_from_main + '
			' + @sql_from + '
			where /*(arl.AORReleaseID is null or arl.[Current] = 1)
			and */(AOR.Archive = 0 or AOR.Archive = ' + @QFShowArchiveAOR + ') ';


			if @QFRelease != ''
				begin
					set @sql = @sql +
						' and isnull(arl.[ProductVersionID], 0) in (' + @QFRelease + ')';
				end;

			if @QFAORType != ''
				begin
					set @sql = @sql +
						' and isnull(arl.[AORWorkTypeID], 0) in (' + @QFAORType + ')';
				end;

			if @QFVisibleToCustomer != ''
				begin
					set @sql = @sql +
						' and arl.[AORCustomerFlagship] in (' + @QFVisibleToCustomer + ')';
				end;

			if @QFContainsTasks != ''
				begin
					set @sql = @sql +
						' and exists (
							select 1
							from AORRelease arl2
							left join AORReleaseTask art2
							on arl2.AORReleaseID = art2.AORReleaseID
							where arl.AORReleaseID = arl2.AORReleaseID
							and (case 
								when isnull(art2.AORReleaseTaskID, 0) = 0 then 0 
								else 1 
								end IN (' + @QFContainsTasks + '))
						)';
				end;

			if @QFAORProductionStatus != ''
				begin
					set @sql = @sql +
						' and isnull(arl.[WorkloadAllocationID], 0) in (' + @QFAORProductionStatus + ')';
				end;

			if @QFContract != ''
				begin
					set @sql = @sql +
						' and exists (
							select 1
							from AORRelease arl2
							left join [AORReleaseTask] art3
							on arl2.AORReleaseID = art3.AORReleaseID
							left join [WORKITEM] wi3
							on art3.[WORKITEMID] = wi3.[WORKITEMID]
							left join WTS_SYSTEM_CONTRACT wsc2
							on wi3.WTS_SYSTEMID = wsc2.WTS_SYSTEMID
							where arl2.AORReleaseID = arl.AORReleaseID
							--and art3.[WORKITEMID] = rta.[WORKITEMID]
							and isnull(wsc2.CONTRACTID, 0) in (' + @QFContract + ')
							and isnull(wsc2.[Primary], 1) = 1
						)';
				end;

			if @AORID_Filter_arr != ''
			begin
				set @sql = @sql +
					' and isnull(AOR.AORID, 0) in (' + @AORID_Filter_arr + ')';
			end;

			if charindex('TASK', upper(@sql_col_group)) > 0
				begin
					if @QFTaskStatus != ''
						begin
							set @sql = @sql +
								' and isnull(wi.[StatusID], 0) in (' + @QFTaskStatus + ')';
						end;
				end;

			--if charindex('SUB-TASK', upper(@sql_col_group)) > 0
			--	begin
			--		if @QFSubTaskStatus != ''
			--			begin
			--				set @sql = @sql +
			--					' and isnull(wit.[StatusID], 0) in (' + @QFSubTaskStatus + ')';
			--			end;
			--	end;

		if @sql_where != ''
			begin
				set @sql = @sql + '
					 and ' + @sql_where;
			end;

		if (charindex('W_WP_SUB', upper(@sql_from)) > 0 or charindex('W_RC_SUB', upper(@sql_from)) > 0 or charindex('W_CARRY_IN_OUT', upper(@sql_from)) > 0) and (@sql_group_all != '' or @sql_select_task_fields != '')
			begin 
				set @sql = @sql + '
					 group by ' + @sql_group_all + @sql_select_task_fields;
			end;

		set @sql = @sql + '
			) a
			order by' + @sql_order_by +
			@sql_temp_cleanup;

		set	@sql_column_data = 
			'SELECT ''Any'' AS [GROUP], ''Workload Priority'' AS [FIELD] UNION ALL
			SELECT ''Any'' AS [GROUP], ''Resource Count (T.BA.PA.CT)'' AS [FIELD] UNION ALL
			SELECT ''Any'' AS [GROUP], ''Task.Workload.Release Status'' AS [FIELD] UNION ALL
			SELECT ''Any'' AS [GROUP], ''Carry In/Out Count'' AS [FIELD] UNION ALL
			SELECT ''Any'' AS [GROUP], ''Deployment'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Deployment Title'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Deployment Start Date'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Deployment End Date'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''AOR Name'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''AOR #'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Description'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Sort'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Coding Estimated Effort'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Testing Estimated Effort'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Training/Support Estimated Effort'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Stage Priority'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Carry In'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Release'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Tier'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Rank'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Last Meeting'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Next Meeting'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''# Of Meetings'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''# Of Attachments'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''CMMI'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Cyber Review'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Critical Path Team'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''AOR Workload Type'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Visible To Customer'' AS [FIELD] UNION ALL
			--SELECT ''AOR'' AS [GROUP], ''Investigation Status'' AS [FIELD] UNION ALL
			--SELECT ''AOR'' AS [GROUP], ''Technical Status'' AS [FIELD] UNION ALL
			--SELECT ''AOR'' AS [GROUP], ''Customer Design Status'' AS [FIELD] UNION ALL
			--SELECT ''AOR'' AS [GROUP], ''Coding Status'' AS [FIELD] UNION ALL
			--SELECT ''AOR'' AS [GROUP], ''Internal Testing Status'' AS [FIELD] UNION ALL
			--SELECT ''AOR'' AS [GROUP], ''Customer Validation Testing Status'' AS [FIELD] UNION ALL
			--SELECT ''AOR'' AS [GROUP], ''Adoption Status'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''IP1 Status'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''IP2 Status'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''IP3 Status'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Primary System'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''AOR System'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Resources'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Workload Allocation'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Approved'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Approved By'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Approved Date'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Bus Workload Manager'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Dev Workload Manager'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Planned Start'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Planned End'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Actual Start'' AS [FIELD] UNION ALL
			SELECT ''AOR'' AS [GROUP], ''Actual End'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''CR Customer Title'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''CR Internal Title'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''CR Description'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''Rationale'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''Customer Impact'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''CSD Required Now'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''Related Release'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''Design Review'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''CR ITI POC'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''Customer Priority List'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''Government CSRD #'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''ITI Priority'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''Primary SR'' AS [FIELD] UNION ALL
			SELECT ''CR'' AS [GROUP], ''Contract'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR #'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR Submitted By'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR Submitted Date'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR Keywords'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR Websystem'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR Status'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR Type'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR Priority'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''LCMB'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR ITI'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR ITI POC'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''SR Description'' AS [FIELD] UNION ALL
			SELECT ''SR'' AS [GROUP], ''Last Reply'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Affiliated'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Assigned To'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Functionality'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Work Activity'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Organization (Assigned To)'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Percent Complete'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Customer Rank'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Assigned To Rank'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Primary Resource'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Priority'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Product Version'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Production Status'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Status'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Submitted By'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''System(Task)'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''System Suite'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Resource Group'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Work Area'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Primary Task'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Primary Task Title'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Work Task'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Title'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''AOR Release/Deployment MGMT'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''AOR Workload MGMT'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''In Progress Date'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Deployed Date'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Ready For Review Date'' AS [FIELD] UNION ALL
			SELECT ''Work Task'' AS [GROUP], ''Closed Date'' AS [FIELD]
			'
			;
	if @GetColumns = 1
		begin
			set	@sql = @sql_column_data;
		end;
		
	if @Debug = 1
		begin
			select @sql, 1 AS 'AOR #';
		end;
	else
		begin
			execute sp_executesql @sql;
		end;
end;



SELECT 'Executing File [Procedures\AOR_Crosswalk_Multi_Level_Grid.sql]';
GO

