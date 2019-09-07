USE WTS
GO

DELETE FROM [REQUESTTYPE]
GO

SET IDENTITY_INSERT [REQUESTTYPE] ON
GO

INSERT INTO [REQUESTTYPE](REQUESTTYPEID, REQUESTTYPE, [DESCRIPTION], SORT_ORDER)
SELECT 1, 'Other', 'Other / uncategorized work', 99 UNION ALL
SELECT 2, 'CR/PTS', 'SRs/requirements grouped for the next development effort', 1 UNION ALL
SELECT 3, 'R&D', 'new development item for ITI', 1 UNION ALL
SELECT 4, 'IA', 'IA team workload tasks', 1 UNION ALL
SELECT 5, 'CS', 'customer support calls, email and etc...', 1 UNION ALL
SELECT 6, 'SME-SR', 'internal SRs submitted by SMEs', 1 UNION ALL
SELECT 7, 'Internal', 'worked items for ITI only', 1 UNION ALL
SELECT 8, 'Admin', '', 1
EXCEPT
SELECT REQUESTTYPEID, REQUESTTYPE, [DESCRIPTION], SORT_ORDER FROM REQUESTTYPE
GO

SET IDENTITY_INSERT [REQUESTTYPE] OFF
GO
