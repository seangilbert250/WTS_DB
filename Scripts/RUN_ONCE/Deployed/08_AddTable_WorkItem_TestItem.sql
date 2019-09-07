CREATE TABLE [dbo].[WorkItem_TestItem]
(
	[WorkItem_TestItemId] INT IDENTITY NOT NULL PRIMARY KEY, 
    [WORKITEMID] INT NOT NULL, 
    [TestItemID] INT NOT NULL,
	[Archive] [bit] NULL DEFAULT ((0)),
	[CreatedBy] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CreatedDate] [datetime] NOT NULL DEFAULT (getdate()),
	[UpdatedBy] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UpdatedDate] [datetime] NOT NULL DEFAULT (getdate()), 
    CONSTRAINT [FK_WorkItem_TestItem_WORKITEM] FOREIGN KEY ([WORKITEMID]) REFERENCES [WORKITEM]([WORKITEMID]), 
    CONSTRAINT [FK_WorkItem_TestItem_WORKITEM_TestItem] FOREIGN KEY ([TestItemID]) REFERENCES [WORKITEM]([WORKITEMID])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item connected to the main workitemid (e.g. IVT or CVT item)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'WorkItem_TestItem',
    @level2type = N'COLUMN',
    @level2name = N'TestItemID'