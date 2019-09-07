USE WTS
GO

DELETE FROM [ALLOCATION]
GO


DELETE FROM AllocationCategory
GO

INSERT INTO AllocationCategory(AllocationCategory, [Description])
SELECT 'Prod Supp', 'Prod Support Category' UNION ALL
SELECT '15.1A', '15.1A Category' UNION ALL
SELECT '15.1B', '15.1B Category' UNION ALL
SELECT '15.2', '15.2 Category' UNION ALL
SELECT '15.2A', '15.2A Category' UNION ALL
SELECT '15.2B', '15.2B Category' UNION ALL
SELECT 'Catholic University', 'Catholic University Category' UNION ALL
SELECT 'BD', 'BD Category' UNION ALL
SELECT 'CAFDEx U', 'CAFDEx U Category' UNION ALL
SELECT 'CMMI', 'CMMI Category' UNION ALL
SELECT 'Contract Deliverables', 'Contract Deliverables Category' UNION ALL
SELECT 'PfM', 'PfM Category' UNION ALL
SELECT 'Contract Renewal', 'Contract Renewal Category' UNION ALL
SELECT 'Cust Supp', 'Cust Supp Category' UNION ALL
SELECT 'Doc', 'Doc Category' UNION ALL
SELECT 'Engineering(ETS)', 'Engineering(ETS) Category' UNION ALL
SELECT 'Other', 'Other Category' UNION ALL
SELECT 'Other Contracts/Customers', 'Other Contracts/Customers Category' UNION ALL
SELECT 'Routine Tasks', 'Routine Tasks Category' UNION ALL
SELECT 'Server M/A', 'Server M/A Category' UNION ALL
SELECT 'Vacation/PTO', 'Vacation/PTO Category' UNION ALL
SELECT 'MS Partnership', 'MS Partnership Category' UNION ALL
SELECT 'Cyber Security', 'Cyber Security Category' UNION ALL
SELECT 'Quality Assurance', 'Quality Assurance Category'
EXCEPT SELECT AllocationCategory, [Description] FROM AllocationCategory;
GO


DECLARE @ALLOCATIONLIST NVARCHAR(4000);
SET @ALLOCATIONLIST = '15.2|15.1A – Compliance (508)|15.1A – WSMS Rehost Phase 2|15.1A – Risk Based Analysis Tool|15.1A – CAFDEx Restructure|15.1A – Delete No Action Comments (CAFDEx)|15.1B – SRMA Rehost|BD - 15 in 15|BD - Other|CAFDEx University|Catholic University|CMMI|Contract Deliv - MSR|Contract Deliv - Other CDRLs|Contract Deliv - Portfolio Mgmt|Contract Deliv - Trip Reports|Contract Renewal - Contract Renewal|Cust Supp - SR|Cust Supp - Tool Adoption|Doc - CVTs|Doc - Help Files|Doc - Training Slides|Engineering(ETS)|Flying Hour Tool(FH)|Other - Efficiencies/Internal Items|Other - MS Partnership|Other Cont - ALOD Cont Supp|Other Cont - AMC/GIO Cont Supp|Other Cont - ANG Cont Supp|Other Cont - PIC/SYS|Prod Supp - 1269|Prod Supp - Admin|Prod Supp - AMR Supp|Prod Supp - Attachments|Prod Supp - CAFDEx Supp|Prod Supp - CF AFM/PSR|Prod Supp - CP|Prod Supp - Data Extract/Import|Prod Supp - DPEM Supp|Prod Supp - Landing Page|Prod Supp - Maint Grids|Prod Supp - Mass Change|Prod Supp - Master Data|Prod Supp - OOC/Coordination|Prod Supp - POM/PB Support|Prod Supp - QM Grids|Prod Supp - Reports/Datasheets|Prod Supp - SR Module/SR|Prod Supp - SRMA Supp|Prod Supp - UID Supp|Prod Supp - User MGMT Filters/Filters|Prod Supp - User Registration/Sponsorship|Prod Supp - WCN Tools|Prod Supp - WSA-PBO Supp|Prod Supp - WSMS Supp|Routine - Prod Supp/Daily Deploy|Server M/A - Server Migration|Server M/A - Server Main/Admin';

CREATE TABLE #ALLOCLIST(
	ALLOCATION NVARCHAR(50)
);
INSERT INTO #ALLOCLIST(ALLOCATION)
SELECT DISTINCT A.ALLOCATION FROM
(
SELECT [Data] AS ALLOCATION FROM dbo.SPLIT(@ALLOCATIONLIST,'|')
UNION ALL
SELECT DISTINCT
	b.[Allocation Assignment] AS ALLOCATION
FROM
	BugTracker.dbo.bugs b
WHERE
	b.[Allocation Assignment] IS NOT NULL
	AND b.[Allocation Assignment] != ''
) A
;

--SELECT * FROM #ALLOCLIST;

INSERT INTO [ALLOCATION](ALLOCATION)
SELECT ALLOCATION FROM #ALLOCLIST
EXCEPT
SELECT ALLOCATION FROM ALLOCATION
GO

--SELECT * FROM ALLOCATION;

DROP TABLE #ALLOCLIST;
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Prod Supp')
	, SORT_ORDER = 5
WHERE
	ALLOCATION LIKE 'Prod Supp - %';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = '15.2')
	, SORT_ORDER = 2
WHERE
	ALLOCATION LIKE '15.2%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = '15.1A')
	, SORT_ORDER = 3
WHERE
	ALLOCATION LIKE '15.1A%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = '15.1B')
	, SORT_ORDER = 3
WHERE
	ALLOCATION LIKE '15.1B%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Contract Deliverables')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Contract Deliv%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Contract Renewal')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Contract Renewal%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'CMMI')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'CMMI%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Catholic University')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Catholic%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'CAFDEx U')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'CAFDEx U%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'BD')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'BD -%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Engineering(ETS)')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Engineering(ETS)%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Other Contracts/Customers')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Other Cont%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Other')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Other - %';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Routine Tasks')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Routine - %';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Server M/A')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Server M%';
GO

UPDATE ALLOCATION
SET 
	AllocationCategoryID = (SELECT AllocationCategoryID FROM AllocationCategory WHERE AllocationCategory = 'Doc')
	, SORT_ORDER = 99
WHERE
	ALLOCATION LIKE 'Doc - %';
GO
