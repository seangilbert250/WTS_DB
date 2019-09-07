USE WTS
GO

ALTER TABLE WORKITEM
ADD IVTRequired bit not null default 0;

GO

