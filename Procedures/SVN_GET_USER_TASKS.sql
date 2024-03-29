USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SVN_GET_USER_TASKS]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SVN_GET_USER_TASKS]
GO

CREATE PROCEDURE [dbo].[SVN_GET_USER_TASKS]
	@DOMAINNAME VARCHAR(25)

AS
BEGIN
	DECLARE @RESOURCEID int = 0;
	
	SELECT @RESOURCEID = A.WTS_RESOURCEID
	FROM [WTS].[dbo].[WTS_RESOURCE] A
	WHERE A.DOMAINNAME = @DOMAINNAME;


	SELECT
		WORKITEMID 
		,0 AS TASK_NUMBER
	    ,'' + cast(WORKITEMID as varchar) + '' AS 'Task #'
		,TITLE
		,[DESCRIPTION]
		,ASSIGNEDRESOURCEID
		,COMPLETIONPERCENT
		,STATUSID
	FROM [WTS].[dbo].[WORKITEM] B
	WHERE B.COMPLETIONPERCENT < 100 AND B.ASSIGNEDRESOURCEID = @RESOURCEID AND B.STATUSID <> 10 AND B.STATUSID <> 15
		UNION
	SELECT
		WORKITEMID 
		,TASK_NUMBER
	    ,'' + cast(WORKITEMID as varchar) + '-' + cast(TASK_NUMBER as varchar) AS 'Task #'
		,TITLE
		,[DESCRIPTION]
		,ASSIGNEDRESOURCEID
		,COMPLETIONPERCENT
		,STATUSID
	FROM [WTS].[dbo].[WORKITEM_TASK] C
	WHERE C.COMPLETIONPERCENT < 100 AND C.ASSIGNEDRESOURCEID = @RESOURCEID AND C.STATUSID <> 10 AND C.STATUSID <> 15
	ORDER BY WORKITEMID;

	SELECT DISTINCT WTS_RESOURCEID, 
		   FIRST_NAME + ' ' + LAST_NAME AS USERNAME
	FROM [WTS].[dbo].[WTS_RESOURCE]
	WHERE AORResourceTeam = 0
	ORDER BY USERNAME;

	select s.STATUSID,
		s.[STATUS]
	from [STATUS] s
	join StatusType st
	on s.StatusTypeID = st.StatusTypeID
	where upper(st.StatusType) = 'WORK'
	and s.ARCHIVE = 0
	order by s.SORT_ORDER, upper(s.[STATUS]);

	select a.pct as COMPLETIONPERCENT
	from (
		select 0 as pct union all
		select 10 as pct union all
		select 20 as pct union all
		select 30 as pct union all
		select 40 as pct union all
		select 50 as pct union all
		select 60 as pct union all
		select 70 as pct union all
		select 80 as pct union all
		select 90 as pct union all
		select 100 as pct
	) a;
END;

GO