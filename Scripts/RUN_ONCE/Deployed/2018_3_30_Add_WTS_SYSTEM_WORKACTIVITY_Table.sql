USE [WTS]
GO

/****** Object:  Table [dbo].[WTS_SYSTEM_WORKACTIVITY]    Script Date: 3/29/2018 1:40:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WTS_SYSTEM_WORKACTIVITY]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY](
	[WTS_SYSTEM_WORKACTIVITYID] [int] IDENTITY(1,1) NOT NULL,
	[WTS_SYSTEMID] [int] NOT NULL,
	[WorkItemTypeID] [int] NOT NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_WTS_SYSTEM_WORKACTIVITY] PRIMARY KEY CLUSTERED
(
	[WTS_SYSTEM_WORKACTIVITYID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_WTS_SYSTEM_WORKACTIVITY] UNIQUE NONCLUSTERED
(
	[WTS_SYSTEMID] ASC,
	[WorkItemTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY]  WITH CHECK ADD  CONSTRAINT [FK_WTS_SYSTEM_WORKACTIVITY_WORKITEMTYPE] FOREIGN KEY([WorkItemTypeID])
REFERENCES [dbo].[WORKITEMTYPE] ([WorkItemTypeID])
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY] CHECK CONSTRAINT [FK_WTS_SYSTEM_WORKACTIVITY_WORKITEMTYPE]
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY]  WITH CHECK ADD  CONSTRAINT [FK_WTS_SYSTEM_WORKACTIVITY_WTS_SYSTEM] FOREIGN KEY([WTS_SYSTEMID])
REFERENCES [dbo].[WTS_SYSTEM] ([WTS_SYSTEMID])
GO

ALTER TABLE [dbo].[WTS_SYSTEM_WORKACTIVITY] CHECK CONSTRAINT [FK_WTS_SYSTEM_WORKACTIVITY_WTS_SYSTEM]
GO