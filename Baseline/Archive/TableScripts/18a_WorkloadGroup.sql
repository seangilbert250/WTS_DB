USE [WTS]
GO

ALTER TABLE [dbo].[WorkloadGroup] DROP CONSTRAINT [DF__WorkloadG__UPDAT__44801EAD]
GO

ALTER TABLE [dbo].[WorkloadGroup] DROP CONSTRAINT [DF__WorkloadG__UPDAT__438BFA74]
GO

ALTER TABLE [dbo].[WorkloadGroup] DROP CONSTRAINT [DF__WorkloadG__CREAT__4297D63B]
GO

ALTER TABLE [dbo].[WorkloadGroup] DROP CONSTRAINT [DF__WorkloadG__CREAT__41A3B202]
GO

ALTER TABLE [dbo].[WorkloadGroup] DROP CONSTRAINT [DF__WorkloadG__ARCHI__40AF8DC9]
GO

ALTER TABLE [dbo].[WorkloadGroup] DROP CONSTRAINT [DF__WorkloadG__Actua__3FBB6990]
GO

ALTER TABLE [dbo].[WorkloadGroup] DROP CONSTRAINT [DF__WorkloadG__Propo__3EC74557]
GO

/****** Object:  Table [dbo].[WorkloadGroup]    Script Date: 8/20/2015 2:49:51 PM ******/
DROP TABLE [dbo].[WorkloadGroup]
GO

/****** Object:  Table [dbo].[WorkloadGroup]    Script Date: 8/20/2015 2:49:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WorkloadGroup](
	[WorkloadGroupID] [int] IDENTITY(1,1) NOT NULL,
	[WorkloadGroup] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[ProposedPriorityRank] [int] NULL,
	[ActualPriorityRank] [int] NULL,
	[ARCHIVE] [bit] NOT NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL,
	[CREATEDDATE] [datetime] NOT NULL,
	[UPDATEDBY] [nvarchar](255) NOT NULL,
	[UPDATEDDATE] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkloadGroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[WorkloadGroup] ADD  DEFAULT ((99)) FOR [ProposedPriorityRank]
GO

ALTER TABLE [dbo].[WorkloadGroup] ADD  DEFAULT ((99)) FOR [ActualPriorityRank]
GO

ALTER TABLE [dbo].[WorkloadGroup] ADD  DEFAULT ((0)) FOR [ARCHIVE]
GO

ALTER TABLE [dbo].[WorkloadGroup] ADD  DEFAULT ('WTS_ADMIN') FOR [CREATEDBY]
GO

ALTER TABLE [dbo].[WorkloadGroup] ADD  DEFAULT (getdate()) FOR [CREATEDDATE]
GO

ALTER TABLE [dbo].[WorkloadGroup] ADD  DEFAULT ('WTS_ADMIN') FOR [UPDATEDBY]
GO

ALTER TABLE [dbo].[WorkloadGroup] ADD  DEFAULT (getdate()) FOR [UPDATEDDATE]
GO

