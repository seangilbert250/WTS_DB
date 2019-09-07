USE WTS
GO

ALTER TABLE [dbo].[Menu] DROP CONSTRAINT [FK_Menu_MenuType]
GO

/****** Object:  Table [dbo].[Menu]    Script Date: 7/2/2015 2:00:13 PM ******/
DROP TABLE [dbo].[Menu]
GO

/****** Object:  Table [dbo].[Menu]    Script Date: 7/2/2015 2:00:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Menu](
	[MenuID] [int] IDENTITY(1,1) NOT NULL,
	[MenuTypeID] [int] NULL,
	[Menu] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[MenuID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Menu]  WITH CHECK ADD  CONSTRAINT [FK_Menu_MenuType] FOREIGN KEY([MenuTypeID])
REFERENCES [dbo].[MenuType] ([MenuTypeID])
GO

ALTER TABLE [dbo].[Menu] CHECK CONSTRAINT [FK_Menu_MenuType]
GO

