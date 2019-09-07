﻿USE WTS
GO

DELETE FROM [PRIORITYTYPE]
GO

SET IDENTITY_INSERT [PRIORITYTYPE] ON
GO

INSERT INTO [PRIORITYTYPE](PRIORITYTYPEID, PRIORITYTYPE, [DESCRIPTION], SORT_ORDER)
SELECT 1, 'Work Item', 'Overall Priority of Work Item', 1 UNION ALL
SELECT 2, 'Resource', 'Priority Rank for assigned resource', 2 UNION ALL
SELECT 3, 'Operations', 'Operations Priority of Work Request', 3
EXCEPT
SELECT PRIORITYTYPEID, PRIORITYTYPE, [DESCRIPTION], SORT_ORDER FROM PRIORITYTYPE
GO

SET IDENTITY_INSERT [PRIORITYTYPE] OFF
GO


DELETE FROM [PRIORITY]
GO

SET IDENTITY_INSERT [PRIORITY] ON
GO

INSERT INTO [PRIORITY](PRIORITYID, PRIORITYTYPEID, [PRIORITY], [DESCRIPTION], SORT_ORDER)
SELECT 1, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Work Item'), 'High', 'High Priority work item', 1 UNION ALL
SELECT 2, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Work Item'), 'Med', 'Medium Priority work item', 2 UNION ALL
SELECT 3, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Work Item'), 'Low', 'Low Priority work item', 3 UNION ALL
SELECT 4, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Work Item'), 'NA', 'Unspecified(very low) Priority work item', 4 UNION ALL
SELECT 5, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '1', 'Top ranked work item for this resource', 1 UNION ALL
SELECT 6, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '2', '2nd ranked work item for this resource', 2 UNION ALL
SELECT 7, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '3', '3rd ranked work item for this resource', 3 UNION ALL
SELECT 8, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '4', '4th ranked work item for this resource', 4 UNION ALL
SELECT 9, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '5', '5th ranked work item for this resource', 5 UNION ALL
SELECT 10, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '6', '6th ranked work item for this resource', 6 UNION ALL
SELECT 11, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '7', '7th ranked work item for this resource', 7 UNION ALL
SELECT 12, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '8', '8th ranked work item for this resource', 8 UNION ALL
SELECT 13, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '9', '9th ranked work item for this resource', 9 UNION ALL
SELECT 14, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Resource'), '10', '10th ranked work item for this resource', 10 UNION ALL
SELECT 15, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Operations'), 'High', '', 1 UNION ALL
SELECT 16, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Operations'), 'Med', '', 2 UNION ALL
SELECT 17, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Operations'), 'Low', '', 3 UNION ALL
SELECT 18, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Operations'), 'Auxiliary', '', 4 UNION ALL
SELECT 19, (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'Operations'), 'NA', '', 5
EXCEPT
SELECT PRIORITYID, PRIORITYTYPEID, [PRIORITY], [DESCRIPTION], SORT_ORDER FROM PRIORITY
GO

SET IDENTITY_INSERT [PRIORITY] OFF
GO