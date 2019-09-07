USE [WTS]
GO

/****** Object:  Table [dbo].[DeploymentContract]    Script Date: 4/5/2018 10:20:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DeploymentContract](
	[DeploymentContractID] [int] IDENTITY(1,1) NOT NULL,
	[ContractID] [int] NOT NULL,
	[DeliverableID] [int] NOT NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DeploymentContract] PRIMARY KEY CLUSTERED 
(
	[DeploymentContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_DeploymentContract] UNIQUE NONCLUSTERED 
(
	[ContractID] ASC,
	[DeliverableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DeploymentContract] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[DeploymentContract] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[DeploymentContract] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[DeploymentContract] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[DeploymentContract] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[DeploymentContract]  WITH CHECK ADD  CONSTRAINT [FK_DeploymentContract_CONTRACT] FOREIGN KEY([ContractID])
REFERENCES [dbo].[CONTRACT] ([ContractID])
GO

ALTER TABLE [dbo].[DeploymentContract] CHECK CONSTRAINT [FK_DeploymentContract_CONTRACT]
GO

ALTER TABLE [dbo].[DeploymentContract]  WITH CHECK ADD  CONSTRAINT [FK_DeploymentContract_ReleaseSchedule] FOREIGN KEY([DeliverableID])
REFERENCES [dbo].[ReleaseSchedule] ([ReleaseScheduleID])
GO

ALTER TABLE [dbo].[DeploymentContract] CHECK CONSTRAINT [FK_DeploymentContract_ReleaseSchedule]
GO
