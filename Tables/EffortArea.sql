CREATE TABLE [dbo].[EffortArea]
(
	[EffortAreaID] INT IDENTITY NOT NULL PRIMARY KEY, 
    [EffortArea] NCHAR(50) NOT NULL, 
    [Description] NVARCHAR(MAX) NULL, 
    [SORT_ORDER] INT NULL DEFAULT 0,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()), 
    CONSTRAINT [AK_EffortArea_Unique] UNIQUE ([EffortArea])
)
