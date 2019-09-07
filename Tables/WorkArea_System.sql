CREATE TABLE [dbo].[WorkArea_System]
(
	[WorkArea_SystemId] INT IDENTITY NOT NULL PRIMARY KEY, 
    [WorkAreaID] INT NOT NULL, 
    [WTS_SYSTEMID] INT NULL, 
    [Description] NVARCHAR(MAX) NULL,
	[ProposedPriority] INT NULL DEFAULT 99, 
    [ApprovedPriority] INT NULL DEFAULT 99,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()), 
    CONSTRAINT [FK_WorkArea_System_WorkArea] FOREIGN KEY ([WorkAreaID]) REFERENCES [WorkArea]([WorkAreaID]), 
    CONSTRAINT [FK_WorkArea_System_WTS_SYSTEM] FOREIGN KEY ([WTS_SYSTEMID]) REFERENCES [WTS_SYSTEM]([WTS_SYSTEMID]), 
    CONSTRAINT [UK_WorkArea_System_WorkAreaSystem] UNIQUE ([WorkAreaID],[WTS_SYSTEMID])
)
