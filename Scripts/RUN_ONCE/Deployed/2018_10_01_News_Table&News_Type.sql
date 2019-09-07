USE [WTS]
GO



USE [WTS]
GO


/****** Object:  Table [dbo].[NewsType]    Script Date: 10/1/2018 3:30:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NewsType]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[NewsType](
	[NewsTypeID] [int] IDENTITY(1,1) NOT NULL,
	[NewsType] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[NewsTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

USE WTS
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[News_Attachment]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[News_Attachment](
	[News_AttachmentId] [int] IDENTITY(1,1) NOT NULL,
	[NewsId] [int] NOT NULL,
	[AttachmentId] [int] NOT NULL,
	[Archive] [bit] NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[News_AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[News_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_NewsAttachment_Attachment] FOREIGN KEY([AttachmentId])
REFERENCES [dbo].[Attachment] ([AttachmentId])


ALTER TABLE [dbo].[News_Attachment] CHECK CONSTRAINT [FK_NewsAttachment_Attachment]


ALTER TABLE [dbo].[News_Attachment]  WITH CHECK ADD  CONSTRAINT [FK_NewsAttachment_News] FOREIGN KEY([NewsId])
REFERENCES [dbo].[News] ([NewsID])


ALTER TABLE [dbo].[News_Attachment] CHECK CONSTRAINT [FK_NewsAttachment_News]

END

GO


GO

use [WTS]
GO

IF NOT EXISTS (SELECT * FROM NewsType WHERE NewsType = 'News Article')
BEGIN
	INSERT INTO [dbo].[NewsType] ([NewsType]) VALUES ('News Article')
END

IF NOT EXISTS (SELECT * FROM NewsType WHERE NewsType = 'News Overview')
BEGIN
	INSERT INTO [dbo].[NewsType] ([NewsType]) VALUES ('News Overview')
END



ALTER TABLE news 
	ADD NewsTypeID int,
	FOREIGN KEY(NewsTypeID) REFERENCES [NewsType](NewsTypeID);
go

update News set NewsTypeID = 1;	
	
ALTER TABLE news ALTER COLUMN NewsTypeID int NOT NULL
GO
