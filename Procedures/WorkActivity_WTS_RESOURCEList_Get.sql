USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkActivity_WTS_RESOURCEList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkActivity_WTS_RESOURCEList_Get]

GO

CREATE PROCEDURE [dbo].[WorkActivity_WTS_RESOURCEList_Get]
	@WORKITEMTYPEID int = null
AS
BEGIN

	DECLARE @columns nvarchar(max), @sql nvarchar(max);

	set @columns = '';
	select @columns += CASE when charindex(QUOTENAME(WTS_SYSTEM_SUITE + ' Action Team'), @columns) > 0 then '' 
						else ', (select distinct case when wasr.ActionTeam = 1 then 1 else 0 end 
								from WorkActivity_System_Resource wasr 
								join WTS_SYSTEM ws on wasr.WTS_SYSTEMID = ws.WTS_SYSTEMID 
								where wasr.WTS_RESOURCEID = p.WTS_RESOURCEID 
								and (ISNULL(' +  CONVERT(NVARCHAR(10), @WORKITEMTYPEID) + ',0) = 0 OR wasr.WORKITEMTYPEID = ' +  CONVERT(NVARCHAR(10), @WORKITEMTYPEID) + ')
								and ws.WTS_SYSTEM_SUITEID in ( 
									select wss.WTS_SYSTEM_SUITEID
									from WTS_SYSTEM_SUITE wss
									left join WTS_SYSTEM ws on wss.WTS_SYSTEM_SUITEID = ws.WTS_SYSTEM_SUITEID
									where ws.WTS_SYSTEM = ''' + WTS_SYSTEM + ''')) as ' + QUOTENAME(WTS_SYSTEM_SUITE + ' Action Team') 
						end + ', max(p.' + QUOTENAME(WTS_SYSTEM) + ') as ' + QUOTENAME(WTS_SYSTEM)
	from (select DISTINCT wss.SORTORDER, ws.WTS_SYSTEM, wss.WTS_SYSTEM_SUITE 
	FROM WTS_SYSTEM ws
	join WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as x
	group by x.WTS_SYSTEM, x.WTS_SYSTEM_SUITE, x.SORTORDER
	order by x.SORTORDER;
	
	set @sql = '
	SELECT min(WorkActivity_WTS_RESOURCEID) as WorkActivity_WTS_RESOURCEID
        , max(WORKITEMTYPEID) as WORKITEMTYPEID
        , max(WORKITEMTYPE) as WORKITEMTYPE
        , WTS_RESOURCEID
        , USERNAME
        , max(IntakeTeam) as IntakeTeam
        , ' + STUFF(@columns, 1, 2, '') + 
        ', ARCHIVE
        , X';

	set @columns = '';
	select @columns += CASE when charindex(QUOTENAME(WTS_SYSTEM_SUITE + ' ActionTeam'), @columns) > 0 then '' else ', p.' + QUOTENAME(WTS_SYSTEM_SUITE + ' ActionTeam') end + ', p.' + QUOTENAME(WTS_SYSTEM)
	from (select DISTINCT wss.SORTORDER, ws.WTS_SYSTEM, wss.WTS_SYSTEM_SUITE 
	FROM WTS_SYSTEM ws
	join WTS_SYSTEM_SUITE wss on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID) as x
	group by x.WTS_SYSTEM, x.WTS_SYSTEM_SUITE, x.SORTORDER
	order by x.SORTORDER;

	set @sql = @sql + '
	FROM (
		--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT
			0 AS WorkActivity_WTS_RESOURCEID
			, 0 AS WORKITEMTYPEID
			, '''' AS WORKITEMTYPE
			, 0 AS WTS_RESOURCEID
			, '''' AS USERNAME
			, '''' as IntakeTeam
			, '''' as WTS_SYSTEM
			, 0 as ActionTeam
			, '''' as ResourceName
			, 0 AS ARCHIVE
			, '''' AS X

		UNION 

		SELECT
			ww.WorkActivity_WTS_RESOURCEID
			, WIT.WORKITEMTYPEID
			, WIT.WORKITEMTYPE
			, wr.WTS_RESOURCEID
			, wr.USERNAME
			, '''' as IntakeTeam
			, '''' as WTS_SYSTEM
			, 0 as ActionTeam
			, wr.USERNAME as ResourceName
			, ww.ARCHIVE
			, '''' as X
		FROM
			WorkActivity_WTS_RESOURCE ww
				LEFT JOIN WORKITEMTYPE WIT ON ww.WORKITEMTYPEID = WIT.WORKITEMTYPEID
				LEFT JOIN WTS_RESOURCE wr ON ww.WTS_RESOURCEID = wr.WTS_RESOURCEID
		WHERE  
			(ISNULL(' +  CONVERT(NVARCHAR(10), @WORKITEMTYPEID) + ',0) = 0 OR WIT.WORKITEMTYPEID = ' +  CONVERT(NVARCHAR(10), @WORKITEMTYPEID) + ')

		union

		SELECT
            9999 as WorkActivity_WTS_RESOURCEID
            , WIT.WORKITEMTYPEID
            , WIT.WORKITEMTYPE
            , wr.WTS_RESOURCEID
            , wr.USERNAME
            , '''' as IntakeTeam
            , ws.WTS_SYSTEM
            , wasr.ActionTeam
            , wr.USERNAME as ResourceName
            , 0 as ARCHIVE
            , '''' as X
        FROM
			WorkActivity_System_Resource wasr
                LEFT JOIN WORKITEMTYPE WIT ON wasr.WORKITEMTYPEID = WIT.WORKITEMTYPEID
                LEFT JOIN WTS_RESOURCE wr ON wasr.WTS_RESOURCEID = wr.WTS_RESOURCEID
                left join WTS_SYSTEM ws on wasr.WTS_SYSTEMID = ws.WTS_SYSTEMID
        WHERE  
            (ISNULL(' +  CONVERT(NVARCHAR(10), @WORKITEMTYPEID) + ',0) = 0 OR WIT.WORKITEMTYPEID = ' +  CONVERT(NVARCHAR(10), @WORKITEMTYPEID) + ')

		union

		SELECT
			(select top 1 wawr.WorkActivity_WTS_RESOURCEID from WorkActivity_WTS_RESOURCE wawr order by wawr.WorkActivity_WTS_RESOURCEID desc) + ROW_NUMBER() OVER(ORDER BY wr.WTS_RESOURCEID ASC) as WorkActivity_WTS_RESOURCEID
			, 0 as WORKITEMTYPEID
			, '''' as WORKITEMTYPE
			, wr.WTS_RESOURCEID
			, wr.USERNAME
			, ''Intake Team Member'' as IntakeTeam
			, '''' as WTS_SYSTEM
			, 0 as ActionTeam
			, wr.USERNAME as ResourceName
			, 0 as ARCHIVE
			, '''' as X
		FROM
			WTS_RESOURCE wr
			join WTS_SYSTEM_RESOURCE wsr on wr.WTS_RESOURCEID = wsr.WTS_RESOURCEID
			left join WorkActivity_System_Resource wasr on wr.WTS_RESOURCEID = wasr.WTS_RESOURCEID
			left join WTS_SYSTEM ws on wasr.WTS_SYSTEMID = ws.WTS_SYSTEMID
		WHERE
			wsr.ActionTeam = 1
		group by wr.USERNAME, wr.WTS_RESOURCEID
	) as j
	PIVOT
	(
		COUNT(ResourceName) FOR WTS_SYSTEM IN (' + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '') + ')
	) as p
	group by p.WTS_RESOURCEID, p.USERNAME, p.ARCHIVE, p.X
	ORDER BY USERNAME ASC'

	--select @sql;
	EXEC sp_executesql @sql;

END;

