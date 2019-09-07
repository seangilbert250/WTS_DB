USE WTS
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

INSERT INTO [WORKREQUEST](REQUESTTYPEID,RequestGroupID,ORGANIZATIONID,WTS_SCOPEID,TITLE,DESCRIPTION,PROGRESSID)
	SELECT DISTINCT 
		WR.REQUESTTYPEID
		, RG.RequestGroupID
		, WR.ORGANIZATIONID
		, WR.WTS_SCOPEID
		, CRL.CR AS TITLE
		, CRL.CR AS [DESCRIPTION] 
		, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop') AS PROGRESSID
	FROM 
		(SELECT 
				RT.REQUESTTYPEID
				, O.ORGANIZATIONID
				, WS.WTS_SCOPEID
			FROM 
				REQUESTTYPE RT
				, ORGANIZATION O
				, WTS_SCOPE WS
			WHERE
				RT.REQUESTTYPE = 'CR/PTS'
				AND O.ORGANIZATION = 'Folsom Dev'
				AND WS.[SCOPE] = 'New Development'
		) WR
		, #CRLIST CRL
		, RequestGroup RG
	WHERE
		CRL.CR = RG.RequestGroup
EXCEPT SELECT REQUESTTYPEID,RequestGroupID,ORGANIZATIONID,WTS_SCOPEID,TITLE,[DESCRIPTION],PROGRESSID FROM WORKREQUEST
	;
GO

	
DROP TABLE #CRLIST;
GO

SELECT COUNT(*) FROM WORKREQUEST;