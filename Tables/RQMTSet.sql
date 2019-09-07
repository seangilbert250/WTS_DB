USE [WTS]
GO

ALTER TABLE [dbo].[RQMTSet] DROP CONSTRAINT [FK_RQMTSet_WorkArea_System]
GO

ALTER TABLE [dbo].[RQMTSet] DROP CONSTRAINT [FK_RQMTSet_RQMTSetType]
GO

/****** Object:  Table [dbo].[RQMTSet]    Script Date: 5/11/2018 4:07:34 PM ******/
DROP TABLE [dbo].[RQMTSet]
GO

/****** Object:  Table [dbo].[RQMTSet]    Script Date: 5/11/2018 4:07:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RQMTSet](
	[RQMTSetID] [int] IDENTITY(1,1) NOT NULL,
	[WorkArea_SystemId] [int] NOT NULL,
	[RQMTSetTypeID] [int] NOT NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RQMTSetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RQMTSet]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSet_RQMTSetType] FOREIGN KEY([RQMTSetTypeID])
REFERENCES [dbo].[RQMTSetType] ([RQMTSetTypeID])
GO

ALTER TABLE [dbo].[RQMTSet] CHECK CONSTRAINT [FK_RQMTSet_RQMTSetType]
GO

ALTER TABLE [dbo].[RQMTSet]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSet_WorkArea_System] FOREIGN KEY([WorkArea_SystemId])
REFERENCES [dbo].[WorkArea_System] ([WorkArea_SystemId])
GO

ALTER TABLE [dbo].[RQMTSet] CHECK CONSTRAINT [FK_RQMTSet_WorkArea_System]
GO


