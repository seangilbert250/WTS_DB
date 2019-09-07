USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AOR_CR_Crosswalk_Multi_Level_Grid]    Script Date: 5/16/2018 1:22:19 PM ******/
DROP PROCEDURE [dbo].[AOR_CR_Crosswalk_Multi_Level_Grid]
GO

/****** Object:  StoredProcedure [dbo].[AOR_CR_Crosswalk_Multi_Level_Grid]    Script Date: 5/16/2018 1:22:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[AOR_CR_Crosswalk_Multi_Level_Grid]
	@SessionID nvarchar(100),
	@UserName nvarchar(100),
	@Level xml,
	@Filter xml,
	@AORID int = 0,
	@AORReleaseID int = 0,
	@CRID int = 0,
	@CRRelatedRel nvarchar(max) = '',
	@CRStatus nvarchar(255) = '',
	@SRStatus nvarchar(255) = '',
	@CRContract nvarchar(255) = '',
	@QFName nvarchar(255) = '',
	@Debug bit = 0
as
begin
	set nocount on;

	declare @date nvarchar(30);
	declare @sql nvarchar(max) = '';
	declare @sql_select nvarchar(max) = '';
	declare @sql_where nvarchar(max) = '';
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
	select @sql_select = stuff((select ', ' + [dbo].[AOR_CR_Get_Columns](columnName, 0, @AORID, '', '') from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_where = stuff((select distinct ' ' + [dbo].[AOR_CR_Get_Columns](fieldName, 1, @AORID, fieldID, '') from w_filter for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, ''),
		   @sql_order_by = stuff((select ', ' + [dbo].[AOR_CR_Get_Columns](columnName, 2, @AORID, '', columnSort) from w_breakout for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');

	if @sql_select = ''
		begin
			select 'No Data Found' as 'CR';
			return;
		end;

	if right(@sql_where, 4) = 'and '
		begin
			set @sql_where = left(@sql_where, len(@sql_where) - 4)
		end;

	set @sql = '
		with w_sr_count as (
			select acr.CRID,
				count(asr.SRID) as SRCount
			from AORCR acr
			left join AORSR asr
			on acr.CRID = asr.CRID
			group by acr.CRID
		),
		w_task_count as (
			select asr.SRID,
				count(wi.WORKITEMID) as TaskCount
			from AORSR asr
			left join WORKITEM wi
			on asr.SRID = wi.SR_Number
			group by asr.SRID
		),
		 w_Rel_Release as (
			select *
			from (
				select distinct acr.CRID, isnull(rtrim(ltrim(Data)),-1) as [Release]
				from AORCR acr
				left join AORReleaseCR arc
				on acr.CRID = arc.CRID
				CROSS APPLY SPLIT(acr.[RelatedRelease], '','')
			) a
		  ),
		   w_Rel_Release_QF as (
			select *
			from (
				select distinct  isnull(rtrim(ltrim(Data)),-1) as [Release]
				from SPLIT(''' + @CRRelatedRel + ''', '','')
			) a
		  )
		select distinct null as X,' +
			@sql_select + ',' +
			' null as Z
		from AORCR acr
		left join [PRIORITY] p
		on acr.CriticalityID = p.PRIORITYID
		left join [STATUS] s
		on acr.StatusID = s.STATUSID
		left join w_sr_count wsc
		on acr.CRID = wsc.CRID
		left join AORSR asr
		on acr.CRID = asr.CRID
		left join AORReleaseCR arc
		on acr.CRID = arc.CRID
		left join AORRelease arl
		on arc.AORReleaseID = arl.AORReleaseID
		left join AOR
		on arl.AORID = AOR.AORID
		left join WORKITEM wi
		on asr.SRID = wi.SR_Number
		left join WTS_SYSTEM ws
		on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		left join ProductVersion pv
		on wi.ProductVersionID = pv.ProductVersionID
		left join [STATUS] ps
		on wi.ProductionStatusID = ps.STATUSID
		left join [PRIORITY] pr
		on wi.PRIORITYID = pr.PRIORITYID
		left join WTS_RESOURCE ato
		on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
		left join WTS_RESOURCE ptr
		on wi.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
		left join WTS_RESOURCE str
		on wi.SECONDARYRESOURCEID = str.WTS_RESOURCEID
		left join WTS_RESOURCE pbr
		on wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID
		left join WTS_RESOURCE sbr
		on wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID
		left join [STATUS] st
		on wi.STATUSID = st.STATUSID
		left join w_task_count wtc
		on asr.SRID = wtc.SRID
		left join w_Rel_Release wrr
		on acr.CRID = wrr.CRID
		left join w_Rel_Release_QF wrqf
		on CHARINDEX(convert(nvarchar(10), wrqf.[Release]), wrr.[Release]) > 0
		left join AORReleaseSystem ars 
		on arl.AORReleaseID = ars.AORReleaseID
		left join WTS_SYSTEM_CONTRACT wc 
		on ars.WTS_SYSTEMID = wc.WTS_SYSTEMID
		left join [CONTRACT] c
		on wc.ContractID = c.CONTRACTID
		';

	if (@AORReleaseID = 0)
		begin
			set @sql = @sql + '
				where isnull(arl.[Current], 1) = 1';
		end;
	else
		begin
			set @sql = @sql + '
				where arl.AORReleaseID = ' + convert(nvarchar(10), @AORReleaseID);
		end;

	if (@AORID != 0)
		begin
			set @sql = @sql + '
				and arl.AORID = ' + convert(nvarchar(10), @AORID);
		end;

	if (@CRID != 0)
		begin
			set @sql = @sql + '
				and acr.CRID = ' + convert(nvarchar(10), @CRID);
		end;
		
	if (@CRRelatedRel != '')
		begin
		set @sql = @sql + '
		and (isnull(''' + @CRRelatedRel + ''','''') = '''' OR CHARINDEX(convert(nvarchar(10), wrqf.[Release]), wrr.[Release]) > 0)';
		end;

	if (@CRStatus != '')
		begin
			set @sql = @sql + '
				and isnull(acr.StatusID, 0) in (' + @CRStatus + ')';
		end;

	if (@SRStatus != '')
		begin
			set @sql = @sql + '
				and isnull(asr.[Status], '''') in (''' + REPLACE(@SRStatus,',',''',''') + ''')';
		end;
		
	if (@CRContract != '')
		begin
			set @sql = @sql + '
				and ((isnull(wc.CONTRACTID, -1) in (' + @CRContract + ') and (isnull(wc.[Primary], 0) = 1))
					or (isnull(wc.CONTRACTID, 0) in (' + @CRContract + '))
				)';
		end;

	if (@QFName != '')
		begin
			set @sql = @sql + 'and (isnull(''' + @QFName + ''', '''') = '''' or charindex(''' + @QFName + ''', acr.CRName) > 0)';

		end;
	
	if @sql_where != ''
		begin
			set @sql = @sql + '
				and ' + @sql_where;
		end;

	set @sql = @sql + '
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




GO

