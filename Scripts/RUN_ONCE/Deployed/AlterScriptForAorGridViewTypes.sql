USE WTS

GO

CREATE TABLE [dbo].[GridViewType]
(
	[GridViewTypeID] INT IDENTITY NOT NULL PRIMARY KEY, 
    [ViewType] NCHAR(50) NOT NULL, 
    [Description] NVARCHAR(128) NULL
)


GO

INSERT INTO GridViewType (ViewType, Description)
VALUES ('GridView', 'All tabs and values');


INSERT INTO GridViewType (ViewType, Description)
VALUES ('TabView', 'Single Tab values');


alter table gridview
add ViewType int NOT NULL DEFAULT 1
