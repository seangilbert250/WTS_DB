USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_Crosswalk_Multi_Level_Grid]    Script Date: 10/4/2018 1:47:46 PM ******/
DROP PROCEDURE [dbo].[RQMT_Crosswalk_Multi_Level_Grid]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_Crosswalk_Multi_Level_Grid]    Script Date: 10/4/2018 1:47:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












CREATE procedure [dbo].[RQMT_Crosswalk_Multi_Level_Grid]
	@SessionID nvarchar(100),
	@UserName nvarchar(100),
	@Level xml,
	@Filter xml,
	@WhereExts xml,
	@Debug bit = 0,
	@RQMTMode nvarchar(100) = 'all', -- combined/rqmttops/rqmtbottoms/rqmtbottomsexclusive
	@CountColumns xml = null,
	@CustomWhere nvarchar(max) = null,
	@IgnoreUserFilters bit = 0
as
begin
	set nocount on;

	declare @date nvarchar(30);
	declare @sql nvarchar(max) = '';
	declare @sql_select nvarchar(max) = '';
	declare @sql_from nvarchar(max) = '';
	declare @sql_where nvarchar(max) = '';
	declare @sql_where_ext nvarchar(max) = '';
	declare @sql_group nvarchar(max) = '';
	declare @sql_order_by nvarchar(max) = '';

	declare @sql_select_count nvarchar(max) = '';
	
	set @date = convert(nvarchar(30), getdate());

	create table #months ( [Month] INT, MonthName NVARCHAR(20))
	insert into #months values (1, 'January')
	insert into #months values (2, 'February')
	insert into #months values (3, 'March')
	insert into #months values (4, 'April')
	insert into #months values (5, 'May')
	insert into #months values (6, 'June')
	insert into #months values (7, 'July')
	insert into #months values (8, 'August')
	insert into #months values (9, 'September')
	insert into #months values (10, 'October')
	insert into #months values (11, 'November')
	insert into #months values (12, 'December');
	
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
	),
	w_filter_where_exts as (
		select
			tbl.filter_where_exts.value('field[1]', 'varchar(100)') as fieldName,
			tbl.filter_where_exts.value('id[1]', 'varchar(100)') as fieldID
		from @WhereExts.nodes('/whereexts/whereext') as tbl(filter_where_exts)
	),
	w_select_count as (
		select
			tbl.countcolumns.value('column[1]', 'varchar(100)') as columnName
		from @CountColumns.nodes('countcolumns/breakout') as tbl(countcolumns)
	)
	select @sql_select = stuff((select ', ' + [dbo].[RQMT_Get_Columns](columnName, 0, '', '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_from = stuff((select distinct tableName from (select ' ' + [dbo].[RQMT_Get_Tables](columnName, 0) as tableName from w_breakout union select ' ' + [dbo].[RQMT_Get_Tables](fieldName, 0) as tableName from w_filter) allTables for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_where = stuff((select distinct ' ' + [dbo].[RQMT_Get_Columns](fieldName, 1, fieldID, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_where_ext = stuff((select distinct ' ' + [dbo].[RQMT_Get_Columns](fieldName, 4, fieldID, '') from w_filter_where_exts for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_group = stuff((select case when [dbo].[RQMT_Get_Columns](columnName, 2, '', '') <> '' then (', ' + [dbo].[RQMT_Get_Columns](columnName, 2, '', '')) else '' end from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_order_by = stuff((select case when [dbo].[RQMT_Get_Columns](columnName, 3, '', columnSort) <> '' then (', ' + [dbo].[RQMT_Get_Columns](columnName, 3, '', columnSort)) else '' end from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_select_count = stuff((select ', ' + [dbo].[RQMT_Get_Columns](columnName, 6, '', '') from w_select_count for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '')

	if @sql_select = ''
		begin
			select 'No Data Found' as 'RQMT';
			return;
		end;

	if right(@sql_where, 4) = 'and '
		begin
			set @sql_where = left(@sql_where, len(@sql_where) - 4)
		end;

	--set @sql_group = replace(replace(@sql_group, ', null', ''), 'null', '');

	-- note: we are joining the UserFilter using a left join, but adding a where clause for it; this will allow us to pull only things that have a UserFilter entry but
	-- also pull RQMTs that have no classification at all

	set @sql = (case when @CountColumns is null then ' select * from ' else ' select ' + @sql_select_count + ', count(1) as ChildCount from ' end) + '(' +		
			'select distinct null as X, null as Y, ' +
				@sql_select + ',

				null as Z

			from RQMT r
			
			left join RQMTSystem rs
			on r.RQMTID = rs.RQMTID

			left join RQMTSet_RQMTSystem rsrs
			on rsrs.RQMTSystemID = rs.RQMTSystemID

			left join User_Filter uf
			on (uf.SessionID = ''' + @SessionID + ''' AND uf.FilterTypeID = 5 AND uf.FilterID = rsrs.RQMTSet_RQMTSystemID)
			
			left join RQMTSet rset
			on rset.RQMTSetID = rsrs.RQMTSetID
			
			left join RQMTSetType rsettype
			on rsettype.RQMTSetTypeID = rset.RQMTSetTypeID
			
			left join RQMTType rt
			on rt.RQMTTypeID = rsettype.RQMTTypeID
			
			left join RQMTSetName rsetname
			on rsetname.RQMTSetNameID = rsettype.RQMTSetNameID
			
			left join WorkArea_System was
			on was.WorkArea_SystemId = rset.WorkArea_SystemId
			
			left join WorkArea wa
			on wa.WorkAreaID = was.WorkAreaID
			
			left join WTS_SYSTEM sys
			on sys.WTS_SYSTEMID = was.WTS_SYSTEMID

			left join RQMTAttribute ra_status
			on ra_status.RQMTAttributeID = rs.RQMTStatusID

			left join RQMTAttribute ra_critical
			on ra_critical.RQMTAttributeID = rs.CriticalityID

			left join RQMTAttribute ra_stage
			on ra_stage.RQMTAttributeID = rs.RQMTStageID

			left join RQMTComplexity rsetcomp
			on rsetcomp.RQMTComplexityID = rset.RQMTComplexityID

			
			
			left join RQMTSet_RQMTSystem rsrsparent
			on rsrsparent.RQMTSet_RQMTSystemID = rsrs.ParentRQMTSet_RQMTSystemID

			left join RQMTSystem rsparent
			on rsparent.RQMTSystemID = rsrsparent.RQMTSystemID

			left join RQMT rparent
			on rparent.RQMTID = rsparent.RQMTID


			
			left join RQMTSet_RQMTSystem rsrschild
			on rsrschild.ParentRQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID

			left join RQMTSystem rschild
			on rschild.RQMTSystemID = rsrschild.RQMTSystemID

			left join RQMT rchild
			on rchild.RQMTID = rschild.RQMTID

			' +	@sql_from + '
			where isnull(r.Archive, 0) = 0 and (' + CONVERT(VARCHAR(1), @IgnoreUserFilters) + ' = 1 or uf.FilterID IS NOT NULL)'
			+
			(
				case 
					when @RQMTMode = 'rqmttops' then ' and rsrsparent.RQMTSet_RQMTSystemID is null'
					when @RQMTMode = 'rqmtbottoms' then ' and rsrschild.RQMTSet_RQMTSystemID is null'
					--when @RQMTMode = 'parentwithchildren' then ' and rsrschild.RQMTSet_RQMTSystemID is not null'
					when @RQMTMode = 'rqmtbottomsexclusive' then ' and rsrsparent.RQMTSet_RQMTSystemID is not null'
					else ''
				end
			);



	if @sql_where != ''
		begin
			set @sql = @sql + '
				and ' + @sql_where;
		end;

	if @sql_where_ext != ''
		begin
			set @sql = @sql  + ' and ' + @sql_where_ext
		end

	if @CustomWhere is not null and @CustomWhere != ''
		begin
			set @sql = @sql + ' and ' + @CustomWhere
		end
		
	if @sql_group != ''
		begin
			set @sql = @sql + '
				group by ' + @sql_group;
		end;

	set @sql = @sql + ') a' +
		(case when @CountColumns is null then '' else ' group by ' + @sql_select_count end) +
		(case when @CountColumns is null then ' order by' + @sql_order_by else ' order by ' + @sql_select_count end);
		
	if @Debug = 1-- or @CountColumns is not null -- UNCOMMENT THE "OR" CLAUSE TO SEE THE COUNT COLUMN QUERY
		begin		
			set @sql = '--------------------@RQMTMode=' + @RQMTMode + '--------------------@Levels=' + CAST(@Level AS VARCHAR(MAX)) + '--------------------
			' + @sql 
			select @sql;
		end;
	else
		begin
			execute sp_executesql @sql;
		end;

	drop table #months
end;
GO


