ALTER TABLE WorkItem_History
ALTER COLUMN OldValue varchar(max) null;

GO

ALTER TABLE WorkItem_History
ALTER COLUMN NewValue varchar(max) null;