USE WTS
GO

INSERT INTO [STATUS] (StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
VALUES (1, 'Requested', 'Work Item is requested but needs authorization before starting', 16);
	
GO

declare @StatusID decimal;
Select @StatusID = (select Statusid from [status] where [STATUS] = 'Requested');
INSERT INTO STATUS_WorkType(STATUSID, WorkTypeID)
VALUES (@StatusID, 3);
	
GO