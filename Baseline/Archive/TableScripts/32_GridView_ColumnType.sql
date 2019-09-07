USE [WTS]
GO

ALTER TABLE [dbo].[GridView_ColumnType] DROP CONSTRAINT [DF__GridView___ARCHI__30441BD6]
GO

/****** Object:  Table [dbo].[GridView_ColumnType]    Script Date: 8/27/2015 10:40:23 AM ******/
DROP TABLE [dbo].[GridView_ColumnType]
GO

/****** Object:  Table [dbo].[GridView_ColumnType]    Script Date: 8/27/2015 10:40:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GridView_ColumnType](
	[GridView_ColumnTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ColumnType] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[ARCHIVE] [bit] NOT NULL,
	[SORT_ORDER] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[GridView_ColumnTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[GridView_ColumnType] ADD  DEFAULT ((0)) FOR [ARCHIVE]
GO

