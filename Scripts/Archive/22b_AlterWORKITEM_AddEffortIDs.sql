USE WTS
GO

ALTER TABLE WORKITEM
ADD EstimatedEffortID int null
	, ActualEffortID int null
;

GO

ALTER TABLE WORKITEM
ADD CONSTRAINT [FK_WORKITEM_EstimatedEffort] FOREIGN KEY ([EstimatedEffortID]) REFERENCES [EffortSize]([EffortSizeID]);

GO

ALTER TABLE WORKITEM
ADD CONSTRAINT [FK_WORKITEM_ActualEffort] FOREIGN KEY ([ActualEffortID]) REFERENCES [EffortSize]([EffortSizeID]);

GO
