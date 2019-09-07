USE WTS
GO

ALTER TABLE GridView
ADD [SessionID] NVARCHAR(100) NULL, 
	[Tier1Columns] NVARCHAR(1000) NULL, 
    [Tier1ColumnOrder] NVARCHAR(MAX) NULL, 
    [Tier1SortOrder] NVARCHAR(1000) NULL, 
    [Tier1RollupGroup] NVARCHAR(50) NULL, 	
    [Tier2Columns] NVARCHAR(1000) NULL, 
    [Tier2ColumnOrder] NVARCHAR(MAX) NULL, 
    [Tier2SortOrder] NVARCHAR(1000) NULL, 
    [Tier2RollupGroup] NVARCHAR(50) NULL, 	
    [Tier3Columns] NVARCHAR(1000) NULL, 
    [Tier3ColumnOrder] NVARCHAR(MAX) NULL, 
    [Tier3SortOrder] NVARCHAR(1000) NULL;
	
GO
