USE [WTS]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] DROP CONSTRAINT [FK_WorkActivityGroup_Phase_WorkActivityGroup]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] DROP CONSTRAINT [FK_WorkActivityGroup_Phase_PDDTDR_PHASE]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] DROP CONSTRAINT [DF__WorkActiv__Updat__5522FCCF]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] DROP CONSTRAINT [DF__WorkActiv__Updat__542ED896]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] DROP CONSTRAINT [DF__WorkActiv__Creat__533AB45D]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] DROP CONSTRAINT [DF__WorkActiv__Creat__52469024]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] DROP CONSTRAINT [DF__WorkActiv__Archi__51526BEB]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] DROP CONSTRAINT [DF__WorkActivi__Sort__505E47B2]
GO

/****** Object:  Table [dbo].[WorkActivityGroup_Phase]    Script Date: 10/9/2018 2:51:41 PM ******/
DROP TABLE [dbo].[WorkActivityGroup_Phase]
GO

/****** Object:  Table [dbo].[WorkActivityGroup_Phase]    Script Date: 10/9/2018 2:51:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WorkActivityGroup_Phase](
	[WorkActivityGroup_PhaseID] [int] IDENTITY(1,1) NOT NULL,
	[WorkActivityGroupID] [int] NOT NULL,
	[PDDTDR_PHASEID] [int] NOT NULL,
	[Sort] [int] NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_WorkActivityGroup_Phase] PRIMARY KEY CLUSTERED 
(
	[WorkActivityGroup_PhaseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] ADD  DEFAULT ((0)) FOR [Sort]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase]  WITH CHECK ADD  CONSTRAINT [FK_WorkActivityGroup_Phase_PDDTDR_PHASE] FOREIGN KEY([PDDTDR_PHASEID])
REFERENCES [dbo].[PDDTDR_PHASE] ([PDDTDR_PHASEID])
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] CHECK CONSTRAINT [FK_WorkActivityGroup_Phase_PDDTDR_PHASE]
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase]  WITH CHECK ADD  CONSTRAINT [FK_WorkActivityGroup_Phase_WorkActivityGroup] FOREIGN KEY([WorkActivityGroupID])
REFERENCES [dbo].[WorkActivityGroup] ([WorkActivityGroupID])
GO

ALTER TABLE [dbo].[WorkActivityGroup_Phase] CHECK CONSTRAINT [FK_WorkActivityGroup_Phase_WorkActivityGroup]
GO


