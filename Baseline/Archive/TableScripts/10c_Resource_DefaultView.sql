USE [WTS]
GO

ALTER TABLE [dbo].[Resource_DefaultView] DROP CONSTRAINT [FK_Resource_DefaultView_GridView]
GO

ALTER TABLE [dbo].[Resource_DefaultView] DROP CONSTRAINT [FK_Resource_DefaultView_GridName]
GO

ALTER TABLE [dbo].[Resource_DefaultView] DROP CONSTRAINT [DF__Resource___UPDAT__37510C18]
GO

ALTER TABLE [dbo].[Resource_DefaultView] DROP CONSTRAINT [DF__Resource___UPDAT__365CE7DF]
GO

ALTER TABLE [dbo].[Resource_DefaultView] DROP CONSTRAINT [DF__Resource___CREAT__3568C3A6]
GO

ALTER TABLE [dbo].[Resource_DefaultView] DROP CONSTRAINT [DF__Resource___CREAT__34749F6D]
GO

/****** Object:  Table [dbo].[Resource_DefaultView]    Script Date: 8/14/2015 2:42:19 PM ******/
DROP TABLE [dbo].[Resource_DefaultView]
GO

/****** Object:  Table [dbo].[Resource_DefaultView]    Script Date: 8/14/2015 2:42:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Resource_DefaultView](
	[Resource_DefaultViewID] [int] IDENTITY(1,1) NOT NULL,
	[WTS_RESOURCEID] [int] NOT NULL,
	[GridNameID] [int] NOT NULL,
	[GridViewID] [int] NOT NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL,
	[CREATEDDATE] [datetime] NOT NULL,
	[UPDATEDBY] [nvarchar](255) NOT NULL,
	[UPDATEDDATE] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Resource_DefaultViewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Resource_DefaultView] ADD  DEFAULT ('WTS_ADMIN') FOR [CREATEDBY]
GO

ALTER TABLE [dbo].[Resource_DefaultView] ADD  DEFAULT (getdate()) FOR [CREATEDDATE]
GO

ALTER TABLE [dbo].[Resource_DefaultView] ADD  DEFAULT ('WTS_ADMIN') FOR [UPDATEDBY]
GO

ALTER TABLE [dbo].[Resource_DefaultView] ADD  DEFAULT (getdate()) FOR [UPDATEDDATE]
GO

ALTER TABLE [dbo].[Resource_DefaultView]  WITH CHECK ADD  CONSTRAINT [FK_Resource_DefaultView_GridName] FOREIGN KEY([GridNameID])
REFERENCES [dbo].[GridName] ([GridNameID])
GO

ALTER TABLE [dbo].[Resource_DefaultView] CHECK CONSTRAINT [FK_Resource_DefaultView_GridName]
GO

ALTER TABLE [dbo].[Resource_DefaultView]  WITH CHECK ADD  CONSTRAINT [FK_Resource_DefaultView_GridView] FOREIGN KEY([GridViewID])
REFERENCES [dbo].[GridView] ([GridViewID])
GO

ALTER TABLE [dbo].[Resource_DefaultView] CHECK CONSTRAINT [FK_Resource_DefaultView_GridView]
GO

