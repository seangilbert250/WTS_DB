USE WTS
GO

UPDATE BugTracker.dbo.bugs
SET [CR Number] = 'CR 19589 - SRMA Rehost'
WHERE
	([CR Number] = ''
		OR [CR Number] IS NULL)
	AND [Allocation Assignment] = '15.1B – SRMA Rehost';
GO

UPDATE BugTracker.dbo.bugs
SET [CR Number] = 'Warranty'
WHERE
	([CR Number] = ''
		OR [CR Number] IS NULL)
	AND (
		[Allocation Assignment] = 'Prod Supp - AMR Supp'
		OR [Allocation Assignment] = 'Prod Supp - CAFDEx Supp'
		OR [Allocation Assignment] = 'Prod Supp - DPEM Supp'
		OR [Allocation Assignment] = 'Prod Supp - QM Grids'
		OR [Allocation Assignment] = 'Prod Supp - SRMA Supp'
		OR [Allocation Assignment] = 'Prod Supp - UID Supp'
		OR [Allocation Assignment] = 'Prod Supp - WSA-PBO Supp'
		OR [Allocation Assignment] = 'Prod Supp - WSMS Supp'
		OR [Allocation Assignment] = 'Prod Supp - Production Support'
	);
GO

UPDATE BugTracker.dbo.bugs
SET 
	bg_assigned_to_user = (SELECT us_id FROM BugTracker.dbo.users WHERE us_username = 'BUSINESS_COMPLETE')
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

UPDATE BugTracker.dbo.bugs
SET 
	[CR Number] = 'Flying Hour Tool'
WHERE 
	bg_project IN (SELECT pj_id FROM BugTracker.dbo.projects WHERE pj_name = 'Flying Hours')
	AND ([CR Number] IS NULL OR [CR Number] = '');
GO

--Prod Support
UPDATE BugTracker.dbo.bugs
SET 
	[CR Number] = 'Warranty'
WHERE 
	bg_project IN (SELECT pj_id FROM BugTracker.dbo.projects WHERE pj_name IN ('AMR','CAFDEx','DPEM','FRM','SRMA','UID','WSA-PBO','WSMS'))
	AND Production = 'Yes'
	AND ([CR Number] IS NULL OR [CR Number] = '');
GO


DECLARE @CRLIST NVARCHAR(4000);
SET @CRLIST = 'CR 22419 Program Group Rollback|CR 22210 RM Ability to See SPM Signature Page|CR 11166 CAM Performance Monitoring|CR 24362 OOC Coordination Comments|CR 8353 Fund Source Maintenance|CR 22390 Obs Crosswalk Enhancement|CR 12060 Risk Based Analysis Tool|CR 8525 FRM Variance Tracking|CR 12124 Restructure Factor Table|CR_OFCO (Need to add possibly PTS - TBd)|Workload Tracking System|CAFDOx|CR 23290 CAFDEx News Email|CR 8440 Program Parade Review Functionality|CR 8526 FRM Budget Docs|CR 24576 Work Spec Find & Replace|CR 25138 AMR Work Spec Collaboration|CR 24577 Work Spec Attachments|Training Support - LMS|Flying Hour Tool|CR 2382 Change Proposal Module|Proposal Capacity|CR 22152 WSA My Collaboration Grid|CR 19589 SRMA Rehost|CMMI (Internal)|CR 25168 LRDP Brochure Pull - table|CR 20556 OOC 1 Yr LRDP-table';
SET @CRLIST = @CRLIST + 'AMR Work Spec Attachments|CR 22390 - Obs Crosswalk Enhancements|CR 8353 - Funds Source Maintenance|CR 23290 - CAFDEx News Email|CR 24362 - OOC Coordination|CR 8970 - AMR Collaboration|CR 1893 - RQMTs Management Changes|CR 9022 - Software Methodology|CR 11848 - WSMS Rehost|CR 11928 - CCARS Interface|CR 8704 - Category Attachments|CR 11941 - Coordination |CR 11961 - Automate OOC|CR 8525 - OOC Variance Tracking|CR 8522 - FRM Induction Tracking|CR 8522 - FRM Induction Tracking (ACFT Sched)|CR 10844 - AMR Ops Code|CR 15102 - AMR Auto Proposed Hours|CR 11832 - AMR WSC Report|CR 8532 - Datacall Notes|CR 8526 - Budget Docs|PTS 19821 - OCO Obligations|CR 8507 - FRM/CRIS Obligation |CR 8507 - Change File |CR 8507 - 1269 PSR Load Sheet|CR 16399 - Target POM Tools|CR 16399 - Target POM Tools (QM Attribute)|CR 2382 - Prioritization |CR 2382 - FRM Traceability (CP)|CLIN & Contract|CR 1893|CR 15392|CR 11195|CR 9733|CR 11426|CR 16870 - MCO|Internal|CR 12060 - Risk Analysis|CR 5275 - CAFDEx News|CR 9658 - Contingency RQMT|CR 19411 - FRM Usability and Modernization|CAFDEx University|CR 8543 - RQMT Deferrals|CR 8705 - Update AMR Hours|CR 12124 - Factor Table|CR 8702 - Compliance (508)|CR 21805 - Delete No Action Comments (CAFDEx)|CR 19589 - SRMA Rehost|CR 11848 - WSMS Rehost Phase 2|CR 19589 CAFDEx Restructure';

CREATE TABLE #CRLIST(
	CR NVARCHAR(150)
);
INSERT INTO #CRLIST(CR)
SELECT DISTINCT C.CR FROM 
(
SELECT [Data] AS CR FROM dbo.SPLIT(@CRLIST,'|')
UNION ALL
SELECT DISTINCT 
	b.[CR Number] AS CR
FROM 
	BugTracker.dbo.bugs b
WHERE
	b.[CR Number] IS NOT NULL
	AND b.[CR Number] != ''
) C
;

--SELECT * FROM #CRLIST;

DELETE FROM RequestGroup
WHERE RequestGroupID NOT IN (
	SELECT DISTINCT RequestGroupID FROM WORKREQUEST WHERE RequestGroupID IS NOT NULL
);
GO

INSERT INTO RequestGroup(RequestGroup,[Description])
SELECT 'Prod Support', 'Generic Production Support bucket'
;
GO

INSERT INTO RequestGroup(RequestGroup,[DESCRIPTION])
	SELECT DISTINCT CRL.CR AS TITLE, CRL.CR AS [DESCRIPTION]
	FROM 
		#CRLIST CRL
EXCEPT SELECT RequestGroup,[DESCRIPTION] FROM RequestGroup
	;
GO

UPDATE RequestGroup
SET SORT_ORDER = 99
WHERE RequestGroup IN (SELECT DISTINCT RequestGroup FROM #CRLIST);
GO
	
DROP TABLE #CRLIST;
GO

--SELECT * FROM RequestGroup;

GO
