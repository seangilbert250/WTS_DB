USE WTS
GO

DELETE FROM [MenuType]
GO

DECLARE @MenuTypeList NVARCHAR(4000);
SET @MenuTypeList = 'Administration|AMR Maintenance|Attachments|Basic Tools|BEM(Budget Exec MGMT)|Collaboration|Compatability|Coordination|CP|CVT/Help Menu|Data Extracts/Import|Datasheets|Global|File Maintenance|Filters|FRM Administration|FRM Landing Page|Internal Training|Maintenance|Mass Change|Master Data|Metrics|Notification|Quick Maintenance|Registration/Sponsorship|Reports|Servers|SR/SR Module|Systems Operation|Target Tools|WCN Tools';

CREATE TABLE #MenuTypeList(
	MenuType NVARCHAR(50)
);
INSERT INTO #MenuTypeList(MenuType)
SELECT DISTINCT MenuType FROM
(
SELECT DISTINCT [Data] AS MenuType FROM dbo.SPLIT(@MenuTypeList,'|')
UNION ALL
SELECT DISTINCT
	b.[Menu Type] AS MenuType
FROM
	BugTracker.dbo.bugs b
WHERE
	b.[Menu Type] IS NOT NULL
	AND b.[Menu Type] != ''
) M
;

--SELECT * FROM #MenuTypeList;

INSERT INTO MenuType(MenuType)
SELECT MenuType FROM #MenuTypeList
EXCEPT
SELECT MenuType FROM MenuType
GO

--SELECT * FROM MenuType;

DROP TABLE #MenuTypeList;
GO

