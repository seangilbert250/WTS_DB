USE WTS
GO

ALTER TABLE [dbo].[AORRelease_History] DROP CONSTRAINT [FK_AORRelease_History_AORRelease]
GO

ALTER TABLE [dbo].[AORRelease_History] DROP CONSTRAINT [FK_AORRelease_History_ITEM_UPDATETYPE]
GO

/****** Object:  Table [dbo].[AORRelease_History]    Script Date: 9/28/2015 12:00:00 PM ******/
DROP TABLE [dbo].[AORRelease_History]
GO

/****** Object:  Table [dbo].[AORRelease_History]    Script Date: 9/28/2015 12:00:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AORRelease_History](
	[AORRelease_HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[ITEM_UPDATETYPEID] [int] NOT NULL,
	[AORReleaseID] [int] NOT NULL,
	[FieldChanged] [nvarchar](50) NOT NULL,
	[OldValue] [varchar](max) NULL,
	[NewValue] [varchar](max) NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED
(
	[AORRelease_HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[AORRelease_History]  WITH CHECK ADD CONSTRAINT [FK_AORRelease_History_AORRelease] FOREIGN KEY([AORReleaseID])
REFERENCES [dbo].[AORRelease] ([AORReleaseID])
GO

ALTER TABLE [dbo].[AORRelease_History] CHECK CONSTRAINT [FK_AORRelease_History_AORRelease]
GO

ALTER TABLE [dbo].[AORRelease_History]  WITH CHECK ADD CONSTRAINT [FK_AORRelease_History_ITEM_UPDATETYPE] FOREIGN KEY([ITEM_UPDATETYPEID])
REFERENCES [dbo].[ITEM_UPDATETYPE] ([ITEM_UPDATETYPEID])
GO

ALTER TABLE [dbo].[AORRelease_History] CHECK CONSTRAINT [FK_AORRelease_History_ITEM_UPDATETYPE]
GO

