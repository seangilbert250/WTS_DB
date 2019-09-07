USE [WTS]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_WTS_RESOURCE]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_TechnicalStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_InvestigationStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_InternalTestingStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_CustomerValidationTestingStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_CustomerDesignStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_CodingStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_AORRelease]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_AORAttachmentType]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [FK_AORReleaseAttachment_AdoptionStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [DF__AORReleas__Appro__6700EA91]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [DF__AORReleas__Updat__23D42350]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [DF__AORReleas__Updat__22DFFF17]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [DF__AORReleas__Creat__21EBDADE]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [DF__AORReleas__Creat__20F7B6A5]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] DROP CONSTRAINT [DF__AORReleas__Archi__2003926C]
GO

/****** Object:  Table [dbo].[AORReleaseAttachment]    Script Date: 4/17/2018 2:03:50 PM ******/
DROP TABLE [dbo].[AORReleaseAttachment]
GO

/****** Object:  Table [dbo].[AORReleaseAttachment]    Script Date: 4/17/2018 2:03:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AORReleaseAttachment](
	[AORReleaseAttachmentID] [int] IDENTITY(1,1) NOT NULL,
	[AORReleaseID] [int] NOT NULL,
	[AORAttachmentTypeID] [int] NOT NULL,
	[AORReleaseAttachmentName] [nvarchar](150) NULL,
	[FileName] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[FileData] [varbinary](max) NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
	[InvestigationStatusID] [int] NULL,
	[TechnicalStatusID] [int] NULL,
	[CustomerDesignStatusID] [int] NULL,
	[CodingStatusID] [int] NULL,
	[InternalTestingStatusID] [int] NULL,
	[CustomerValidationTestingStatusID] [int] NULL,
	[AdoptionStatusID] [int] NULL,
	[Approved] [bit] NOT NULL,
	[ApprovedByID] [int] NULL,
	[ApprovedDate] [datetime] NULL,
 CONSTRAINT [PK_AORReleaseAttachment] PRIMARY KEY CLUSTERED 
(
	[AORReleaseAttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_AORReleaseAttachment] UNIQUE NONCLUSTERED 
(
	[AORReleaseID] ASC,
	[AORAttachmentTypeID] ASC,
	[AORReleaseAttachmentName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO

ALTER TABLE [dbo].[AORReleaseAttachment] ADD  DEFAULT ((0)) FOR [Approved]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_AdoptionStatus] FOREIGN KEY([AdoptionStatusID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_AdoptionStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_AORAttachmentType] FOREIGN KEY([AORAttachmentTypeID])
REFERENCES [dbo].[AORAttachmentType] ([AORAttachmentTypeID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_AORAttachmentType]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_AORRelease] FOREIGN KEY([AORReleaseID])
REFERENCES [dbo].[AORRelease] ([AORReleaseID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_AORRelease]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_CodingStatus] FOREIGN KEY([CodingStatusID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_CodingStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_CustomerDesignStatus] FOREIGN KEY([CustomerDesignStatusID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_CustomerDesignStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_CustomerValidationTestingStatus] FOREIGN KEY([CustomerValidationTestingStatusID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_CustomerValidationTestingStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_InternalTestingStatus] FOREIGN KEY([InternalTestingStatusID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_InternalTestingStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_InvestigationStatus] FOREIGN KEY([InvestigationStatusID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_InvestigationStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_TechnicalStatus] FOREIGN KEY([TechnicalStatusID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_TechnicalStatus]
GO

ALTER TABLE [dbo].[AORReleaseAttachment]  WITH CHECK ADD  CONSTRAINT [FK_AORReleaseAttachment_WTS_RESOURCE] FOREIGN KEY([ApprovedByID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[AORReleaseAttachment] CHECK CONSTRAINT [FK_AORReleaseAttachment_WTS_RESOURCE]
GO


