use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AOR_Meeting_Crosswalk_Multi_Level_Grid]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AOR_Meeting_Crosswalk_Multi_Level_Grid]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AOR_Meeting_Crosswalk_Multi_Level_Grid]
	@SessionID nvarchar(100),
	@UserName nvarchar(100),
	@Level xml,
	@Filter xml,
	@AORID int = 0,
	@AORReleaseID int = 0,
	@Debug bit = 0
as
begin
	set nocount on;

	declare @date nvarchar(30);
	declare @sql nvarchar(max) = '';
	declare @sql_with nvarchar(max) = '';
	declare @sql_select nvarchar(max) = '';
	declare @sql_from nvarchar(max) = '';
	declare @sql_where nvarchar(max) = '';
	declare @sql_group nvarchar(max) = '';
	declare @sql_order_by nvarchar(max) = '';
	
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
	select @sql_select = stuff((select ', ' + [dbo].[AOR_Meeting_Get_Columns](columnName, 0, '', '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_from = stuff((select distinct tableName from (select ' ' + [dbo].[AOR_Meeting_Get_Tables](columnName, 0) as tableName from w_breakout union select ' ' + [dbo].[AOR_Meeting_Get_Tables](fieldName, 0) as tableName from w_filter) allTables for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_where = stuff((select distinct ' ' + [dbo].[AOR_Meeting_Get_Columns](fieldName, 1, fieldID, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_group = stuff((select ', ' + [dbo].[AOR_Meeting_Get_Columns](columnName, 2, '', '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_order_by = stuff((select ', ' + [dbo].[AOR_Meeting_Get_Columns](columnName, 3, '', columnSort) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');

	if @sql_select = ''
		begin
			select 'No Data Found' as 'Meeting';
			return;
		end;

	if right(@sql_where, 4) = 'and '
		begin
			set @sql_where = left(@sql_where, len(@sql_where) - 4)
		end;

	set @sql_group = replace(replace(@sql_group, ', null', ''), 'null', '');

	if charindex('W_LAST_MEETING', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_last_meeting as (
					select ami.AORMeetingID,
						max(ami.InstanceDate) as LastMeeting
					from AORMeetingInstance ami
					where ami.InstanceDate < ''' + @date + '''
					group by ami.AORMeetingID
				),';
		end;

	if charindex('W_NEXT_MEETING', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_next_meeting as (
					select ami.AORMeetingID,
						min(ami.InstanceDate) as NextMeeting
					from AORMeetingInstance ami
					where ami.InstanceDate > ''' + @date + '''
					group by ami.AORMeetingID
				),';
		end;

	if charindex('W_MEETING_ATTENDANCE', upper(@sql_from)) > 0
		begin
			set @sql_with = @sql_with + '
				w_meeting_attendance as (
					select a.AORMeetingID,
						min(a.AttendanceCount) as MinCount,
						max(a.AttendanceCount) as MaxCount,
						sum(a.AttendanceCount) / count(a.AORMeetingInstanceID) as AvgCount
					from (
						select ami.AORMeetingID,
							ami.AORMeetingInstanceID,
							count(ara.WTS_RESOURCEID) as AttendanceCount
						from AORMeetingInstance ami
						left join AORMeetingResourceAttendance ara
						on ami.AORMeetingInstanceID = ara.AORMeetingInstanceID
						where ami.InstanceDate < ''' + @date + '''
						group by ami.AORMeetingID,
							ami.AORMeetingInstanceID
					) a
					group by a.AORMeetingID
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

	set @sql =
		@sql_with + '
		select * from (select distinct null as X,' + @sql_select;
		
		if charindex('WEEKSTART', upper(@sql_select)) > 0 and charindex('WEEKEND', upper(@sql_select)) > 0
			begin
				set @sql = @sql + ', '''' as Week';
			end;
		
		set @sql = @sql + ', null as Z
			from AORMeeting aom
			left join AORMeetingInstance ami
			on aom.AORMeetingID = ami.AORMeetingID
			left join AORMeetingAOR ama
			on ami.AORMeetingInstanceID = ama.AORMeetingInstanceID_Add
			left join AORRelease arl
			on ama.AORReleaseID = arl.AORReleaseID
			left join AORMeetingResource amr
			on ami.AORMeetingInstanceID = amr.AORMeetingInstanceID_Add
			left join AOR
			on arl.AORID = AOR.AORID ' + @sql_from + '
			where ama.AORMeetingInstanceID_Remove is null
			and amr.AORMeetingInstanceID_Remove is null
			and isnull(AOR.Archive, 0) = 0';

		if (@AORID != 0)
			begin
				set @sql = @sql + '
					and arl.AORID = ' + convert(nvarchar(10), @AORID);
			end;

		if (@AORReleaseID != 0)
			begin
				set @sql = @sql + '
					and arl.AORReleaseID = ' + convert(nvarchar(10), @AORReleaseID);
			end;

		if @sql_where != ''
			begin
				set @sql = @sql + '
					and ' + @sql_where;
			end;
		
		if @sql_group != ''
			begin
				set @sql = @sql + '
					group by ' + @sql_group;
			end;

		set @sql = @sql + ') a
			order by' + @sql_order_by;

	if @Debug = 1
		begin
			select @sql;
		end;
	else
		begin
			execute sp_executesql @sql;
		end;
end;
