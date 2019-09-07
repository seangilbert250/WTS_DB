CREATE TABLE [dbo].[EffortArea_Size]
(
	[EffortArea_SizeID] INT IDENTITY NOT NULL PRIMARY KEY, 
    [EffortAreaID] INT NOT NULL, 
	[EffortSizeID] INT NOT NULL, 
    [MinValue] INT NOT NULL DEFAULT 0, 
    [MaxValue] INT NOT NULL DEFAULT 8, 
    [Unit] NVARCHAR(50) NOT NULL DEFAULT ('Hours'),
    [Description] NVARCHAR(MAX) NULL, 
    [SORT_ORDER] INT NULL DEFAULT 0,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()), 
    CONSTRAINT [FK_EffortArea_Size_EffortArea] FOREIGN KEY ([EffortAreaID]) REFERENCES [EffortArea]([EffortAreaID]), 
    CONSTRAINT [FK_EffortArea_Size_EffortSize] FOREIGN KEY ([EffortSizeID]) REFERENCES [EffortSize]([EffortSizeID]), 
    CONSTRAINT [AK_EffortArea_Size_Unique] UNIQUE ([EffortAreaID],[EffortSizeID])
)
