USE [WTS]
GO

ALTER TABLE [dbo].[ReportQueue] DROP CONSTRAINT [FK_ReportQueue_Type]
GO

ALTER TABLE [dbo].[ReportQueue] DROP CONSTRAINT [FK_ReportQueue_Resource]
GO

ALTER TABLE [dbo].[ReportQueue] DROP CONSTRAINT [FK_ReportQueue_ReportStatus]
GO

/****** Object:  Table [dbo].[ReportQueue]    Script Date: 1/31/2018 4:25:44 PM ******/
DROP TABLE [dbo].[ReportQueue]
GO

/****** Object:  Table [dbo].[ReportQueue]    Script Date: 1/31/2018 4:25:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReportQueue](
	[ReportQueueID] [bigint] IDENTITY(1,1) NOT NULL,
	[Guid] [varchar](50) NOT NULL,
	[WTS_RESOURCEID] [int] NOT NULL,
	[REPORT_TYPEID] [int] NOT NULL,
	[REPORT_STATUSID] [int] NOT NULL,
	[ReportName] [nvarchar](255) NULL,
	[ReportAssembly] [varchar](255) NULL,
	[ReportClass] [varchar](255) NULL,
	[ReportMethod] [varchar](255) NULL,
	[ScheduledDate] [datetime] NULL,
	[CompletedDate] [datetime] NULL,
	[ReportParameters] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Result] [nvarchar](max) NULL,
	[Error] [nvarchar](max) NULL,
	[OutFileName] [varchar](100) NULL,
	[OutFile] [varbinary](max) NULL,
	[Archive] [bit] NOT NULL,
	[OutFileSize] [bigint] NULL,
 CONSTRAINT [PK__ReportQu__E61751DF4812C5D1] PRIMARY KEY CLUSTERED 
(
	[ReportQueueID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReportQueue]  WITH CHECK ADD  CONSTRAINT [FK_ReportQueue_ReportStatus] FOREIGN KEY([REPORT_STATUSID])
REFERENCES [dbo].[REPORT_STATUS] ([REPORT_STATUSID])
GO

ALTER TABLE [dbo].[ReportQueue] CHECK CONSTRAINT [FK_ReportQueue_ReportStatus]
GO

ALTER TABLE [dbo].[ReportQueue]  WITH CHECK ADD  CONSTRAINT [FK_ReportQueue_Resource] FOREIGN KEY([WTS_RESOURCEID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[ReportQueue] CHECK CONSTRAINT [FK_ReportQueue_Resource]
GO

ALTER TABLE [dbo].[ReportQueue]  WITH CHECK ADD  CONSTRAINT [FK_ReportQueue_Type] FOREIGN KEY([REPORT_TYPEID])
REFERENCES [dbo].[REPORT_TYPE] ([REPORT_TYPEID])
GO

ALTER TABLE [dbo].[ReportQueue] CHECK CONSTRAINT [FK_ReportQueue_Type]
GO


