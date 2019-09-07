USE [WTS]
GO

ALTER TABLE [dbo].[RQMTSetType] DROP CONSTRAINT [FK_RQMTSetType_RQMTType]
GO

ALTER TABLE [dbo].[RQMTSetType] DROP CONSTRAINT [FK_RQMTSetType_RQMTSetName]
GO

/****** Object:  Table [dbo].[RQMTSetType]    Script Date: 5/11/2018 4:08:24 PM ******/
DROP TABLE [dbo].[RQMTSetType]
GO

/****** Object:  Table [dbo].[RQMTSetType]    Script Date: 5/11/2018 4:08:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RQMTSetType](
	[RQMTSetTypeID] [int] IDENTITY(1,1) NOT NULL,
	[RQMTSetNameID] [int] NOT NULL,
	[RQMTTypeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RQMTSetTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UC_RQMTSetType] UNIQUE NONCLUSTERED 
(
	[RQMTSetNameID] ASC,
	[RQMTTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RQMTSetType]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSetType_RQMTSetName] FOREIGN KEY([RQMTSetNameID])
REFERENCES [dbo].[RQMTSetName] ([RQMTSetNameID])
GO

ALTER TABLE [dbo].[RQMTSetType] CHECK CONSTRAINT [FK_RQMTSetType_RQMTSetName]
GO

ALTER TABLE [dbo].[RQMTSetType]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSetType_RQMTType] FOREIGN KEY([RQMTTypeID])
REFERENCES [dbo].[RQMTType] ([RQMTTypeID])
GO

ALTER TABLE [dbo].[RQMTSetType] CHECK CONSTRAINT [FK_RQMTSetType_RQMTType]
GO

