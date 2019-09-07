USE [WTS]
GO

ALTER TABLE [dbo].[GridView_SortColumn] DROP CONSTRAINT [FK_GridView_SortColumn_GridView]
GO

ALTER TABLE [dbo].[GridView_SortColumn] DROP CONSTRAINT [DF__GridView___SORT___5ED4ED8D]
GO

ALTER TABLE [dbo].[GridView_SortColumn] DROP CONSTRAINT [DF__GridView___SortD__5DE0C954]
GO

/****** Object:  Table [dbo].[GridView_SortColumn]    Script Date: 8/11/2015 11:07:59 AM ******/
DROP TABLE [dbo].[GridView_SortColumn]
GO

/****** Object:  Table [dbo].[GridView_SortColumn]    Script Date: 8/11/2015 11:07:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GridView_SortColumn](
	[GridView_SortColumnID] [int] IDENTITY(1,1) NOT NULL,
	[GridViewID] [int] NOT NULL,
	[ColumnName] [nvarchar](50) NOT NULL,
	[SortDirection] [nchar](4) NOT NULL,
	[SORT_ORDER] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[GridView_SortColumnID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [AK_GridView_SortColumn_Unique] UNIQUE NONCLUSTERED 
(
	[GridViewID] ASC,
	[ColumnName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GridView_SortColumn] ADD  DEFAULT ('ASC') FOR [SortDirection]
GO

ALTER TABLE [dbo].[GridView_SortColumn] ADD  DEFAULT ((99)) FOR [SORT_ORDER]
GO

ALTER TABLE [dbo].[GridView_SortColumn]  WITH CHECK ADD  CONSTRAINT [FK_GridView_SortColumn_GridView] FOREIGN KEY([GridViewID])
REFERENCES [dbo].[GridView] ([GridViewID])
GO

ALTER TABLE [dbo].[GridView_SortColumn] CHECK CONSTRAINT [FK_GridView_SortColumn_GridView]
GO

