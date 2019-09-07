USE WTS
GO

DELETE FROM [Menu]
GO

DECLARE @MenuList NVARCHAR(4000);
SET @MenuList = '1269 Settings|ACFT Health|ACFT Sched Upload|Add Budget Line|Add Funds Holder|AMR Task RQMT Report|Analysis|Apply Attribute Rule|Attachments|Attribute|Audit|Auto Email MGMT|BEM Crosswalk w Coord PDF Report|Buyback Datasheet|CAFDEx Converged RQMT Report|CF AFM OAC|CF PSR RC/CC|CF Settings|CF Wizard|Compare Stored Data Datasheet|Comparison Utility|CP Main Grid|CP Wizard|Create Target Scenario|CRIS Refer Files|CRIS Ref Upload|Custom Datasheet|Data Accuracy|Data Call Overview|Delete Data Call|Delete Target (No PCNs)|Distribution|Execution Report|Execution Compare Report|Factors Datasheet|FRM Obligation Report|Funds Spread|Funds Spread Xwalk|Get Append Target|Global|ICD|ICD Upload|IE Compatibility|Impact & RQMT Descr|Import/Copy WCN|ITI Efficiency|Manage Category|Manage Data Call|Manage Exercise|Manage Target Scenario (ITI)|Mass Change|Mass Change – Distribution|Mass Change – Funding|Mass Change – RQMT|Mass Change – Target|Mass Change – Obligation|Mass Change Updated By|Mini Contract Oblig|Narrative Datasheet|New Capability|New PCN/Task|News|Obligation|Obligation Xwalk|OOC Coord Grid|OOC Main|OOC Report|OOC Summary Email|Operational Deficiency|PGM/WS Code Clean Up|Pop Up|Prioritization|RAPIDS Upload Sheet|Reports Wizard|Restore Data Call|Risk Assessment|Rollover|RQMT|RQMTs Tab|SAF FM Datasheet|SNaP Datasheet|Spend Plan Report|Success/Failure Point Datasheet|Supp Source|Sync Role Affiliation|Target|Target Audit Datasheet|Target Compare Datasheet|Task Grid|Task Group Grid|Text Field Usability|Trended Datasheet|UI Layout|Usability|User Options|Variance Datasheet|View/Edit Coord|View/Edit CP|WCN Compare Datasheet|WCN Main|WID Report|What If Cut Datasheet|Workload Datasheet|Work Spec';

CREATE TABLE #MenuList(
	Menu NVARCHAR(50)
);
INSERT INTO #MenuList(Menu)
SELECT DISTINCT Menu FROM
(
SELECT DISTINCT [Data] AS Menu FROM dbo.SPLIT(@MenuList,'|')
UNION ALL
SELECT DISTINCT 
	b.[Menu Name] AS Menu
FROM
	BugTracker.dbo.bugs b
WHERE
	b.[Menu Name] IS NOT NULL
	AND b.[Menu Name] != ''
) M
;

--SELECT * FROM #MenuList;

INSERT INTO Menu(Menu)
SELECT Menu FROM #MenuList
EXCEPT
SELECT Menu FROM Menu;
GO

--SELECT * FROM Menu;

DROP TABLE #MenuList;
GO

