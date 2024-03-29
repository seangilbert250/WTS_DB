USE [WTS]
GO

INSERT INTO [dbo].[PRIORITYTYPE](
	  [PRIORITYTYPE]
	, [DESCRIPTION]
	, [SORT_ORDER]
	, [ARCHIVE]
	, [CREATEDBY]
	, [CREATEDDATE]
	, [UPDATEDBY]
	, [UPDATEDDATE]
)
VALUES(
	  'AOR Estimation'
	, 'AOR Risk Estimation'
	, 9
	, 0
	, 'WTS_ADMIN'
	, GETDATE()
	, 'WTS_ADMIN'
	, GETDATE()
);

GO

INSERT INTO [dbo].[PRIORITY](
       [PRIORITYTYPEID]
	  ,[PRIORITY]
      ,[DESCRIPTION]
      ,[SORT_ORDER]
      ,[ARCHIVE]
      ,[CREATEDBY]
      ,[CREATEDDATE]
      ,[UPDATEDBY]
      ,[UPDATEDDATE]
)
SELECT
	(SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'AOR Estimation')
	, 'Low'
	, 'Low AOR Risk Estimation'
	, 3
	, 0
	, 'WTS_ADMIN'
	, GETDATE()
	, 'WTS_ADMIN'
	, GETDATE()
UNION ALL
SELECT
	(SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'AOR Estimation')
	, 'Moderate'
	, 'Moderate AOR Risk Estimation'
	, 2
	, 0
	, 'WTS_ADMIN'
	, GETDATE()
	, 'WTS_ADMIN'
	, GETDATE()
UNION ALL
SELECT
	(SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE = 'AOR Estimation')
	, 'High'
	, 'High AOR Risk Estimation'
	, 1
	, 0
	, 'WTS_ADMIN'
	, GETDATE()
	, 'WTS_ADMIN'
	, GETDATE()
;
GO