USE [WTS]
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
SELECT 'RQMT Status'
     , 'Criticality'
	 , 4
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
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
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Status')
     , 'Pass'
	 , 'RQMT Status: Pass'
	 , 1
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Status')
     , 'Fail'
	 , 'RQMT Status: Fail'
	 , 1
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Status')
     , 'Not Tested'
	 , 'RQMT Status: Not Tested'
	 , 1
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
UNION
SELECT (SELECT RQMTAttributeTypeID FROM RQMTAttributeType WHERE RQMTAttributeType = 'RQMT Status')
     , 'Deficient'
	 , 'RQMT Status: Deficient'
	 , 1
	 , 0
	 , 'WTS_ADMIN'
	 , GETDATE()
GO