USE WTS
GO

UPDATE BugTracker.dbo.bugs
SET 
	bg_assigned_to_user = (SELECT us_id FROM BugTracker.dbo.users WHERE us_username = 'BUS_COMPLETE')
WHERE
	bg_assigned_to_user IS NULL
	OR bg_assigned_to_user = 0;
GO

UPDATE BugTracker.dbo.bugs
SET
	bg_project = (SELECT pj_id FROM BugTracker.dbo.projects WHERE pj_name = 'ALL')
WHERE
	bg_project IS NULL
	OR bg_project = 0;
GO

UPDATE BugTracker.dbo.bugs
SET
	bg_priority = (SELECT pr_id FROM BugTracker.dbo.priorities WHERE pr_name = 'NA')
WHERE
	bg_priority IS NULL
	OR bg_priority = 0;
GO


CREATE TABLE #WORKITEM_BUGS(
	BUGTRACKER_ID int, WORKITEMTYPEID int, WTS_SYSTEMID int, PRIORITYID int, ALLOCATIONID int
	, BT_USERNAME nvarchar(50), BT_FIRST_NAME nvarchar(60), BT_LAST_NAME nvarchar(60), BT_DEV_USERNAME nvarchar(50), BT_DEV_FIRST_NAME nvarchar(60), BT_DEV_LAST_NAME nvarchar(60), BT_DEV2_USERNAME nvarchar(50), BT_DEV2_FIRST_NAME nvarchar(60), BT_DEV2_LAST_NAME nvarchar(60)
	, RESOURCEPRIORITYRANK int, BT_STATUS nvarchar(60), NEEDDATE datetime, ESTIMATEDHOURS int, ESTIMATEDCOMPLETIONDATE datetime, COMPLETIONPERCENT int, TITLE nvarchar(150), [DESCRIPTION] nvarchar(500)
	, ARCHIVE bit, BT_CREATEDBY_FNAME nvarchar(60), BT_CREATEDBY_LNAME nvarchar(60), CREATEDDATE datetime, BT_UPDATEDBY_FNAME nvarchar(60), BT_UPDATEDBY_LNAME nvarchar(60), UPDATEDDATE datetime
	, WORKREQUESTID int, BT_PRODUCTVERSION varchar(10), Production nvarchar(3), BT_MENUTYPE varchar(max), BT_MENUNAME varchar(max), Reproduced_Bus nvarchar(5), Reproduced_Dev nvarchar(5)
	, SR_NUMBER int
	)
INSERT INTO #WORKITEM_BUGS
SELECT 
	BUGTRACKER_ID, WORKITEMTYPEID, WTS_SYSTEMID, PRIORITYID, ALLOCATIONID
	, BT_USERNAME, FIRST_NAME, LAST_NAME, DEVELOPER_USERNAME, DEVELOPER_FIRST_NAME, DEVELOPER_LAST_NAME, DEVELOPER2_USERNAME, DEVELOPER2_FIRST_NAME, DEVELOPER2_LAST_NAME
	, RESOURCEPRIORITYRANK, STATUS, NEEDDATE, ESTIMATEDHOURS, ESTIMATEDCOMPLETIONDATE, COMPLETIONPERCENT
	, TITLE, [DESCRIPTION], ARCHIVE, CREATEDBY_FNAME, CREATEDBY_LNAME, CREATEDDATE, UPDATEDBY_FNAME, UPDATEDBY_LNAME, UPDATEDDATE
	, WORKREQUESTID, [Product Version], Production, [Menu Type], [Menu Name], [Reproduced (BUS)], [Reproduced (DEV)], [SR Number]
FROM (
	--BT ITEMS ASSIGNED TO CR
	SELECT 
		b.bg_id AS BUGTRACKER_ID
		, o.og_name
		, b.[CR Number]
		, wr.WORKREQUESTID --based on CR and item type
		, wr.TITLE AS WR_CR
		, c.ct_name
		, wit.WORKITEMTYPEID
		, p.pj_name AS PROJECT
		, ws.WTS_SYSTEMID
		, pri.pr_name AS PRIORITY
		, wp.PRIORITYID
		, b.[Allocation Assignment] AS ALLOCATION
		, a.ALLOCATIONID
		, au.us_username AS BT_USERNAME
		, au.us_firstname AS FIRST_NAME
		, au.us_lastname AS LAST_NAME
		, du.us_username AS DEVELOPER_USERNAME
		, du.us_firstname AS DEVELOPER_FIRST_NAME
		, du.us_lastname AS DEVELOPER_LAST_NAME
		, sdu.us_username AS DEVELOPER2_USERNAME
		, sdu.us_firstname AS DEVELOPER2_FIRST_NAME
		, sdu.us_lastname AS DEVELOPER2_LAST_NAME
		, CONVERT(int, ISNULL(b.[Developer Priority Rank],0)) AS RESOURCEPRIORITYRANK
		, st.st_name AS [STATUS]
		, b.[Date Needed(BUS)] AS NEEDDATE
		, 0 AS ESTIMATEDHOURS
		, NULL AS ESTIMATEDCOMPLETIONDATE
		, CONVERT(int, ISNULL(B.[Percent Complete],0)) as COMPLETIONPERCENT
		, LEFT(b.bg_short_desc, 150) AS TITLE
		, CASE WHEN ISNULL(b.[CR Number],'') = '' THEN 'Internal: ' + LEFT(b.bg_short_desc, 150) ELSE b.[CR Number] + ': ' + LEFT(b.bg_short_desc, 150) END AS [DESCRIPTION]
		, 0 AS ARCHIVE
		, cu.us_firstname AS CREATEDBY_FNAME
		, cu.us_lastname AS CREATEDBY_LNAME
		, b.bg_reported_date AS CREATEDDATE
		, ISNULL(uu.us_firstname,cu.us_firstname) AS UPDATEDBY_FNAME
		, ISNULL(uu.us_lastname, cu.us_lastname) AS UPDATEDBY_LNAME
		, ISNULL(b.bg_last_updated_date, b.bg_reported_date) AS UPDATEDDATE
		, b.[Product Version]
		, b.Production
		, b.[Menu Type]
		, b.[Menu Name]
		, b.[Reproduced (BUS)]
		, b.[Reproduced (DEV)]
		, b.[SR Number]
	FROM
		BugTracker.dbo.bugs b
			--LEFT JOIN bug_posts bp ON b.bg_id = bp.bp_bug
			LEFT JOIN BugTracker.dbo.projects p ON b.bg_project = p.pj_id
				LEFT JOIN WTS_SYSTEM ws ON p.pj_name = ws.WTS_SYSTEM
			JOIN BugTracker.dbo.priorities pri ON b.bg_priority = pri.pr_id
				JOIN PRIORITY wp ON pri.pr_name = wp.PRIORITY
			JOIN BugTracker.dbo.orgs o ON b.bg_org = o.og_id
			JOIN BugTracker.dbo.users au ON b.bg_assigned_to_user = au.us_id
			LEFT JOIN BugTracker.dbo.users du ON b.Developer = du.us_id
			LEFT JOIN BugTracker.dbo.users sdu ON b.[Support Developer] = sdu.us_id
			JOIN BugTracker.dbo.statuses st ON b.bg_status = st.st_id
			JOIN BugTracker.dbo.users cu ON b.bg_reported_user = cu.us_id
			LEFT JOIN BugTracker.dbo.users uu ON b.bg_last_updated_user = uu.us_id
			LEFT JOIN BugTracker.dbo.categories c ON b.bg_category = c.ct_id
				LEFT JOIN WORKITEMTYPE wit ON c.ct_name = wit.WORKITEMTYPE
			LEFT JOIN ALLOCATION a ON b.[Allocation Assignment] = a.ALLOCATION
			JOIN (SELECT WR.WORKREQUESTID
					, WR.REQUESTTYPEID, RT.REQUESTTYPE
					, WR.ORGANIZATIONID, O.ORGANIZATION
					, WR.WTS_SCOPEID, WS.[SCOPE]
					, WR.TITLE
				FROM 
					WORKREQUEST WR
						JOIN REQUESTTYPE RT ON WR.REQUESTTYPEID = RT.REQUESTTYPEID
						JOIN ORGANIZATION O ON WR.ORGANIZATIONID = O.ORGANIZATIONID
						JOIN WTS_SCOPE WS ON WR.WTS_SCOPEID = WS.WTS_SCOPEID
				WHERE
					RT.REQUESTTYPE = 'CR/PTS'
					AND O.ORGANIZATION = 'Folsom Dev'
					AND WS.[SCOPE] = 'New Development'
			) WR ON b.[CR NUMBER] = WR.TITLE
	WHERE
		b.[CR Number] IS NOT NULL
		AND b.[CR Number] != ''
		AND b.[CR Number] = WR.TITLE
		AND wp.PRIORITYTYPEID = 1
	UNION ALL

	--NO CR ASSIGNED
	SELECT 
		b.bg_id AS BUGTRACKER_ID
		, o.og_name
		, b.[CR Number]
		, wr.WORKREQUESTID --based on CR and item type
		, wr.TITLE AS WR_CR
		, c.ct_name
		, wit.WORKITEMTYPEID
		, p.pj_name AS PROJECT
		, ws.WTS_SYSTEMID
		, pri.pr_name AS PRIORITY
		, wp.PRIORITYID
		, b.[Allocation Assignment] AS ALLOCATION
		, a.ALLOCATIONID
		, au.us_username AS BT_USERNAME
		, au.us_firstname AS FIRST_NAME
		, au.us_lastname AS LAST_NAME
		, du.us_username AS DEVELOPER_USERNAME
		, du.us_firstname AS DEVELOPER_FIRST_NAME
		, du.us_lastname AS DEVELOPER_LAST_NAME
		, sdu.us_username AS DEVELOPER2_USERNAME
		, sdu.us_firstname AS DEVELOPER2_FIRST_NAME
		, sdu.us_lastname AS DEVELOPER2_LAST_NAME
		, CONVERT(int, ISNULL(b.[Developer Priority Rank],0)) AS RESOURCEPRIORITYRANK
		, st.st_name AS [STATUS]
		, b.[Date Needed(BUS)] AS NEEDDATE
		, 0 AS ESTIMATEDHOURS
		, NULL AS ESTIMATEDCOMPLETIONDATE
		, CONVERT(int, ISNULL(B.[Percent Complete],0)) as COMPLETIONPERCENT
		, LEFT(b.bg_short_desc, 150) AS TITLE
		, CASE WHEN ISNULL(b.[CR Number],'') = '' THEN 'Internal' ELSE b.[CR Number] END AS [DESCRIPTION]
		, 0 AS ARCHIVE
		, cu.us_firstname AS CREATEDBY_FNAME
		, cu.us_lastname AS CREATEDBY_LNAME
		, b.bg_reported_date AS CREATEDDATE
		, ISNULL(uu.us_firstname,cu.us_firstname) AS UPDATEDBY_FNAME
		, ISNULL(uu.us_lastname, cu.us_lastname) AS UPDATEDBY_LNAME
		, ISNULL(b.bg_last_updated_date, b.bg_reported_date) AS UPDATEDDATE
		, b.[Product Version]
		, b.Production
		, b.[Menu Type]
		, b.[Menu Name]
		, b.[Reproduced (BUS)]
		, b.[Reproduced (DEV)]
		, b.[SR Number]
	FROM
		BugTracker.dbo.bugs b
			--LEFT JOIN bug_posts bp ON b.bg_id = bp.bp_bug
			LEFT JOIN BugTracker.dbo.projects p ON b.bg_project = p.pj_id
				LEFT JOIN WTS_SYSTEM ws ON p.pj_name = ws.WTS_SYSTEM
			JOIN BugTracker.dbo.priorities pri ON b.bg_priority = pri.pr_id
				JOIN PRIORITY wp ON pri.pr_name = wp.PRIORITY
			JOIN BugTracker.dbo.orgs o ON b.bg_org = o.og_id
			JOIN BugTracker.dbo.users au ON b.bg_assigned_to_user = au.us_id
			LEFT JOIN BugTracker.dbo.users du ON b.Developer = du.us_id
			LEFT JOIN BugTracker.dbo.users sdu ON b.Developer = sdu.us_id
			JOIN BugTracker.dbo.statuses st ON b.bg_status = st.st_id
			JOIN BugTracker.dbo.users cu ON b.bg_reported_user = cu.us_id
			LEFT JOIN BugTracker.dbo.users uu ON b.bg_last_updated_user = uu.us_id
			LEFT JOIN BugTracker.dbo.categories c ON b.bg_category = c.ct_id
				LEFT JOIN WORKITEMTYPE wit ON c.ct_name = wit.WORKITEMTYPE
			LEFT JOIN ALLOCATION a ON b.[Allocation Assignment] = a.ALLOCATION
		, (SELECT WR.WORKREQUESTID
				, WR.REQUESTTYPEID, RT.REQUESTTYPE
				, WR.ORGANIZATIONID, O.ORGANIZATION
				, WR.WTS_SCOPEID, WS.[SCOPE]
				, WR.TITLE
			FROM 
				WORKREQUEST WR
					JOIN REQUESTTYPE RT ON WR.REQUESTTYPEID = RT.REQUESTTYPEID
					JOIN ORGANIZATION O ON WR.ORGANIZATIONID = O.ORGANIZATIONID
					JOIN WTS_SCOPE WS ON WR.WTS_SCOPEID = WS.WTS_SCOPEID
			WHERE
				RT.REQUESTTYPE != 'CR/PTS'
				AND O.ORGANIZATION = 'Folsom Dev'
		) WR
	WHERE
		(b.[CR Number] IS NULL OR b.[CR Number] = '')
		AND wp.PRIORITYTYPEID = 1
		AND WR.[SCOPE] = --'Sustainment'
			CASE c.ct_name
				WHEN 'Task' THEN 'Direct Support'
				WHEN 'Testing/CVT' THEN 'New Development'
				WHEN 'Data Update' THEN 'Direct Support'
				WHEN 'IT' THEN 'Server Configuration'
				WHEN 'Bug' THEN 'Sustainment'
				WHEN 'Business Team' THEN 'Direct Support'
				WHEN 'Question' THEN 'Direct Support'
				WHEN '508 Compliance' THEN 'Sustainment'
				WHEN 'Enhancement' THEN 'New Development'
				WHEN 'Support' THEN 'Direct Support'
				WHEN 'Servers' THEN 'Server Configuration'
				WHEN 'Posting' THEN 'Server Configuration'
				ELSE c.ct_name END
) B
ORDER BY B.CREATEDDATE
;

--SELECT * FROM #WORKITEM_BUGS;

DELETE FROM WORKITEM;
GO

SET IDENTITY_INSERT WORKITEM ON
GO

--ADD TO ACTUAL WORKITEM TABLE
INSERT INTO WORKITEM(
	WORKITEMID, WORKITEMTYPEID, WTS_SYSTEMID, PRIORITYID, ALLOCATIONID, ASSIGNEDRESOURCEID, PRIMARYRESOURCEID, SECONDARYRESOURCEID, RESOURCEPRIORITYRANK, WorkTypeID, STATUSID
	, NEEDDATE, ESTIMATEDHOURS, ESTIMATEDCOMPLETIONDATE, COMPLETIONPERCENT
	, TITLE, [DESCRIPTION], ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE
	, WORKREQUESTID, BUGTRACKER_ID, ProductVersionID, Production, MenuTypeID, MenuNameID, Reproduced_Biz, Reproduced_Dev
	, SR_Number
)
SELECT
	BUGTRACKER_ID AS WORKITEMID
	, ISNULL(wb.WORKITEMTYPEID,14) AS WORKITEMTYPEID
	, wb.WTS_SYSTEMID
	, wb.PRIORITYID
	, wb.ALLOCATIONID
	, ar.WTS_RESOURCEID AS ASSIGNEDRESOURCEID
	, pr.WTS_RESOURCEID AS PRIMARYRESOURCEID
	, sr.WTS_RESOURCEID AS SECONDARYRESOURCEID
	, wb.RESOURCEPRIORITYRANK
	, 3 AS WorkTypeID
	, s.STATUSID
	, wb.NEEDDATE
	, wb.ESTIMATEDHOURS
	, wb.ESTIMATEDCOMPLETIONDATE
	, wb.COMPLETIONPERCENT
	, wb.TITLE
	, wb.[DESCRIPTION]
	, wb.ARCHIVE
	, wb.BT_CREATEDBY_FNAME + '.' + wb.BT_CREATEDBY_LNAME AS CREATEDBY
	, wb.CREATEDDATE
	, wb.BT_UPDATEDBY_FNAME + '.' + wb.BT_UPDATEDBY_LNAME AS UPDATEDBY
	, wb.UPDATEDDATE
	, wb.WORKREQUESTID
	, wb.BUGTRACKER_ID
	, pv.ProductVersionID
	, CASE wb.Production WHEN 'Yes' THEN 1 ELSE 0 END AS Production
	, mt.MenuTypeID
	, m.MenuID AS MenuNameID
	, CASE wb.[Reproduced_Bus] WHEN 'Yes' THEN 1 ELSE 0 END AS Reproduced_Biz
	, CASE wb.[Reproduced_Dev] WHEN 'Yes' THEN 1 ELSE 0 END AS Reproduced_Dev
	, wb.SR_NUMBER
FROM
	#WORKITEM_BUGS wb
		LEFT JOIN WTS_RESOURCE ar ON LTRIM(RTRIM(wb.BT_FIRST_NAME)) + '.' + LTRIM(RTRIM(wb.BT_LAST_NAME)) = ar.USERNAME
		LEFT JOIN WTS_RESOURCE pr ON LTRIM(RTRIM(wb.BT_DEV_FIRST_NAME)) + '.' + LTRIM(RTRIM(wb.BT_DEV_LAST_NAME)) = pr.USERNAME
		LEFT JOIN WTS_RESOURCE sr ON LTRIM(RTRIM(wb.BT_DEV2_FIRST_NAME)) + '.' + LTRIM(RTRIM(wb.BT_DEV2_LAST_NAME)) = sr.USERNAME
		JOIN [STATUS] s ON wb.BT_STATUS = s.[STATUS]
		LEFT JOIN ProductVersion pv ON wb.BT_PRODUCTVERSION = pv.ProductVersion
		LEFT JOIN MenuType mt ON wb.BT_MENUTYPE = mt.MenuType
		LEFT JOIN Menu m ON wb.BT_MENUNAME = m.Menu
EXCEPT
SELECT WORKITEMID, WORKITEMTYPEID, WTS_SYSTEMID, PRIORITYID, ALLOCATIONID, ASSIGNEDRESOURCEID, PRIMARYRESOURCEID, SECONDARYRESOURCEID, RESOURCEPRIORITYRANK, WorkTypeID, STATUSID
	, NEEDDATE, ESTIMATEDHOURS, ESTIMATEDCOMPLETIONDATE, COMPLETIONPERCENT
	, TITLE, [DESCRIPTION], ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE
	, WORKREQUESTID, BUGTRACKER_ID, ProductVersionID, Production, MenuTypeID, MenuNameID, Reproduced_Biz, Reproduced_Dev, SR_Number
FROM WORKITEM
;

SET IDENTITY_INSERT WORKITEM OFF
GO

DECLARE @MaxID INTEGER;
SELECT @MaxID = MAX(WORKITEMID) FROM WORKITEM;
SET @MaxID = ISNULL(@MaxID,0) + 1;

--SELECT @MaxID;

DBCC CHECKIDENT (WORKITEM, RESEED, @MaxID);

GO

DROP TABLE #WORKITEM_BUGS
GO

SELECT COUNT(*) FROM WORKITEM;
--SELECT * FROM WORKITEM;