USE WTS
GO

INSERT INTO StatusType(StatusType, [DESCRIPTION], SORT_ORDER)
VALUES ('Production', 'Production status', 10);

UPDATE ProductVersion
SET ARCHIVE = 1
WHERE UPPER(ProductVersion) IN ('FUTURE','INTERNAL','R&D','TRAINING');

DECLARE @StatusTypeID DECIMAL;
Select @StatusTypeID = (SELECT StatusTypeID FROM StatusType WHERE UPPER(StatusType) = 'PRODUCTION');

INSERT INTO [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
VALUES (@StatusTypeID, 'Internal', 'Workload being completed for ITI benefit in supporting the systems.',  1);

INSERT INTO [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
VALUES (@StatusTypeID, 'R&D', 'Workload being done that is not used in Production today. We''re improving tools to provide a solution for customer to adopt.', 2);

INSERT INTO [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
VALUES (@StatusTypeID, 'Release', 'Workload tied to a release that will follow the PD2TDR process.', 3);

INSERT INTO [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
VALUES (@StatusTypeID, 'Production', 'Workload tied to current production. Production needs resolution within 3 hours and not more than 24 hours. If over 24 hours, need documentation and approval.', 4);

GO

ALTER TABLE WORKITEM
ADD ProductionStatusID INT NULL;

GO

ALTER TABLE WORKITEM
ADD CONSTRAINT [FK_WORKITEM_ProductionStatus] FOREIGN KEY ([ProductionStatusID]) REFERENCES [STATUS]([STATUSID]);

GO
