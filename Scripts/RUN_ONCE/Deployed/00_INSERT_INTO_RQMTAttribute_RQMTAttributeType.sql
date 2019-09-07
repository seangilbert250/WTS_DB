USE [WTS]
GO

--CLEAR OUT EXISTING DATA FROM RQMTAttributeType
DELETE FROM [dbo].[RQMTAttributeType] 
GO

--INSERT NEW VALUES INTO RQMTAttributeType
INSERT INTO [dbo].[RQMTAttributeType](
	  RQMTAttributeType
	, Description
	, SortOrder
	, Archive
	, CreatedBy
	, CreatedDate
)
SELECT 'RQMT Stage'
     , 'RQMT Stage'
	 , 1
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT 'Impact'
     , 'Impact'
	 , 2
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT 'Criticality'
     , 'Criticality'
	 , 3
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
GO

--CLEAR OUT EXISTING DATA FROM RQMTAttribute
DELETE FROM [dbo].[RQMTAttribute]
GO

--INSERT NEW VALUES INTO RQMTAttribute
INSERT INTO [dbo].[RQMTAttribute] (
	RQMTAttributeTypeID
	, RQMTAttribute
	, Description
	, SortOrder
	, Archive
	, CreatedBy
	, CreatedDate
)
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Stage')
     , 'Production'
	 , 'RQMT Stage: Production'
	 , 1
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Stage')
     , 'New Investigation'
	 , 'RQMT Stage: New Investigation'
	 , 2
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Stage')
     , 'Development'
	 , 'RQMT Stage: Development'
	 , 3
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Stage')
     , 'Not Supported'
	 , 'RQMT Stage: Not Supported'
	 , 4
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Stage')
     , 'Production Disabled'
	 , 'RQMT Stage: Production Disabled'
	 , 5
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'Impact')
     , 'Low'
	 , 'Impact: Low'
	 , 1
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'Impact')
     , 'None'
	 , 'Impact: None'
	 , 2
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'Impact')
     , 'Work Stoppage'
	 , 'Impact: Work Stoppage'
	 , 3
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'Criticality')
     , 'Major'
	 , 'Criticality: Major'
	 , 1
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'Criticality')
     , 'Minor'
	 , 'Criticality: Minor'
	 , 2
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'Criticality')
     , 'Critical'
	 , 'Criticality: Critical'
	 , 3
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'Criticality')
     , 'DNT'
	 , 'Criticality: DNT'
	 , 4
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()

GO