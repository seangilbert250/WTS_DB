USE WTS
GO

UPDATE WORKITEM 
SET 
	WORKITEM.SubmittedByID = wr.WTS_RESOURCEID
FROM WTS_RESOURCE wr
WHERE 
	WORKITEM.CREATEDBY = wr.USERNAME;

GO