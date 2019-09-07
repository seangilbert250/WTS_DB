USE [WTS]
GO

/****** Object:  Table [dbo].[RQMTDescriptionAttachment]    Script Date: 9/4/2018 4:37:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RQMTDescriptionAttachment](
	[RQMTDescriptionAttachmentID] [bigint] IDENTITY(1,1) NOT NULL,
	[RQMTDescriptionID] [int] NOT NULL,
	[AttachmentID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RQMTDescriptionAttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RQMTDescriptionAttachment_Attachment]    Script Date: 9/4/2018 4:37:43 PM ******/
CREATE NONCLUSTERED INDEX [IDX_RQMTDescriptionAttachment_Attachment] ON [dbo].[RQMTDescriptionAttachment]
(
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [IDX_RQMTDescriptionAttachment_RQMTDescription]    Script Date: 9/4/2018 4:37:43 PM ******/
CREATE NONCLUSTERED INDEX [IDX_RQMTDescriptionAttachment_RQMTDescription] ON [dbo].[RQMTDescriptionAttachment]
(
	[RQMTDescriptionID] ASC,
	[RQMTDescriptionAttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RQMTDescriptionAttachment]  WITH CHECK ADD  CONSTRAINT [FK_RQMTDescriptionAttachment_Attachment] FOREIGN KEY([AttachmentID])
REFERENCES [dbo].[Attachment] ([AttachmentId])
GO

ALTER TABLE [dbo].[RQMTDescriptionAttachment] CHECK CONSTRAINT [FK_RQMTDescriptionAttachment_Attachment]
GO

ALTER TABLE [dbo].[RQMTDescriptionAttachment]  WITH CHECK ADD  CONSTRAINT [FK_RQMTDescriptionAttachment_RQMTDescription] FOREIGN KEY([RQMTDescriptionID])
REFERENCES [dbo].[RQMTDescription] ([RQMTDescriptionID])
GO

ALTER TABLE [dbo].[RQMTDescriptionAttachment] CHECK CONSTRAINT [FK_RQMTDescriptionAttachment_RQMTDescription]
GO


