USE WTS
GO

ALTER TABLE WorkArea_System
ADD
	[ProposedPriority] INT NULL DEFAULT 99, 
    [ApprovedPriority] INT NULL DEFAULT 99
;

GO
