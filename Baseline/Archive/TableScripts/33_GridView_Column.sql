USE [WTS]
GO

ALTER TABLE [dbo].[GridView_Column] DROP CONSTRAINT [FK_GridView_Column_GridView]
GO

ALTER TABLE [dbo].[GridView_Column] DROP CONSTRAINT [DF__GridView__SORT___591C1437]
GO

/****** Object:  Table [dbo].[GridView_Column]    Script Date: 8/11/2015 11:06:28 AM ******/
DROP TABLE [dbo].[GridView_Column]
GO

/****** Object:  Table [dbo].[GridView_Column]    Script Date: 8/11/2015 11:06:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GridView_Column](
	[GridView_ColumnID] [int] IDENTITY(1,1) NOT NULL,
	[GridViewID] [int] NOT NULL,
    [GridView_ColumnTypeID] INT NULL DEFAULT 1, 
    [ColumnLevel] INT NULL DEFAULT 1, 
	[ColumnName] [nvarchar](50) NOT NULL,
	[DisplayName] NVARCHAR(50) NULL, 
    [IsVisible] BIT NULL DEFAULT 0, 
	[SORT_ORDER] [int] NULL,
    PRIMARY KEY CLUSTERED 
(
	[GridView_ColumnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [AK_GridView_Column_Unique] UNIQUE NONCLUSTERED 
([GridViewID], [GridView_ColumnTypeID], [ColumnLevel], [ColumnName])WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
    CONSTRAINT [FK_GridView_Column_GridView_ColumnType] FOREIGN KEY ([GridView_ColumnTypeID]) REFERENCES [GridView_ColumnType]([GridView_ColumnTypeID])
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GridView_Column] ADD  DEFAULT ((99)) FOR [SORT_ORDER]
GO

ALTER TABLE [dbo].[GridView_Column]  WITH CHECK ADD  CONSTRAINT [FK_GridView_Column_GridView] FOREIGN KEY([GridViewID])
REFERENCES [dbo].[GridView] ([GridViewID])
GO

ALTER TABLE [dbo].[GridView_Column] CHECK CONSTRAINT [FK_GridView_Column_GridView]
GO

