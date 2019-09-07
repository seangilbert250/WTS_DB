USE WTS
GO

ALTER TABLE WORKITEM
ADD [Signed_Bus] BIT NULL DEFAULT 0
, [SignedBy_BusID] INT NULL
, [SignedDate_Bus] DATETIME NULL
, [Signed_Dev] BIT NULL DEFAULT 0
, [SignedBy_DevID] INT NULL
, [SignedDate_Dev] DATETIME NULL;

GO

UPDATE WORKITEM
SET Signed_Bus = 0
	,Signed_Dev = 0;
	
GO