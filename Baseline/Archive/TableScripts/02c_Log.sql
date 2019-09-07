USE WTS
GO

ALTER TABLE [dbo].[LOG] DROP CONSTRAINT [FK_Log_Log_Type]
GO

ALTER TABLE [dbo].[LOG] DROP CONSTRAINT [DF__LOG__CreatedDate__2665ABE1]
GO

ALTER TABLE [dbo].[LOG] DROP CONSTRAINT [DF__LOG__CreatedBy__257187A8]
GO

ALTER TABLE [dbo].[LOG] DROP CONSTRAINT [DF__LOG__MessageDate__247D636F]
GO

ALTER TABLE [dbo].[LOG] DROP CONSTRAINT [DF__LOG__LOG_TYPEID__23893F36]
GO

/****** Object:  Table [dbo].[LOG]    Script Date: 7/2/2015 2:07:54 PM ******/
DROP TABLE [dbo].[LOG]
GO

/****** Object:  Table [dbo].[LOG]    Script Date: 7/2/2015 2:07:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LOG](
	[LOGID] [int] IDENTITY(1,1) NOT NULL,
	[LOG_TYPEID] [int] NOT NULL DEFAULT ((1)),
	[ParentMessageId] [int] NULL,
	[Username] [nvarchar](255) NULL,
	[MessageDate] [datetime2](7) NOT NULL DEFAULT (getdate()),
	[ExceptionType] [nvarchar](255) NULL,
	[Message] [text] NULL,
	[StackTrace] [text] NULL,
	[MessageSource] [nvarchar](200) NULL,
	[AppVersion] [nvarchar](50) NULL,
	[Url] [nvarchar](100) NULL,
	[AdditionalInfo] [text] NULL,
	[MachineName] [nvarchar](50) NULL,
	[ProcessName] [nvarchar](50) NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[LOGID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[LOG]  WITH CHECK ADD  CONSTRAINT [FK_Log_Log_Type] FOREIGN KEY([LOG_TYPEID])
REFERENCES [dbo].[LOG_TYPE] ([LOG_TYPEID])
GO

ALTER TABLE [dbo].[LOG] CHECK CONSTRAINT [FK_Log_Log_Type]
GO

