USE [WTS]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [FK__News__NewsTypeID__1C1F899D]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Bln_Archiv__4AAF8FFD]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Updated_Da__49BB6BC4]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Updated_By__48C7478B]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Created_Da__47D32352]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Created_By__46DEFF19]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Time_Zone__45EADAE0]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Bln_News__44F6B6A7]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Bln_Active__4402926E]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__End_Date__430E6E35]
GO

ALTER TABLE [dbo].[News] DROP CONSTRAINT [DF__News__Start_Date__421A49FC]
GO

/****** Object:  Table [dbo].[News]    Script Date: 10/1/2018 3:28:20 PM ******/
DROP TABLE [dbo].[News]
GO

/****** Object:  Table [dbo].[News]    Script Date: 10/1/2018 3:28:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[News](
	[NewsID] [int] IDENTITY(1,1) NOT NULL,
	[Summary] [nvarchar](50) NULL,
	[Detail] [nvarchar](max) NULL,
	[Sort_Order] [int] NULL,
	[Start_Date] [date] NULL,
	[End_Date] [date] NULL,
	[Bln_Active] [int] NULL,
	[Bln_News] [int] NULL,
	[Time_Zone] [nvarchar](4) NULL,
	[Created_By] [nvarchar](255) NULL,
	[Created_Date] [date] NULL,
	[Updated_By] [nvarchar](255) NULL,
	[Updated_Date] [date] NULL,
	[Bln_Archive] [int] NULL,
	[NewsTypeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[NewsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT (getdate()) FOR [Start_Date]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT (getdate()) FOR [End_Date]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT ((0)) FOR [Bln_Active]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT ((0)) FOR [Bln_News]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT ('EST') FOR [Time_Zone]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT ('WTS_ADMIN') FOR [Created_By]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT (getdate()) FOR [Created_Date]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT ('WTS_ADMIN') FOR [Updated_By]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT (getdate()) FOR [Updated_Date]
GO

ALTER TABLE [dbo].[News] ADD  DEFAULT ((0)) FOR [Bln_Archive]
GO

ALTER TABLE [dbo].[News]  WITH CHECK ADD FOREIGN KEY([NewsTypeID])
REFERENCES [dbo].[NewsType] ([NewsTypeID])
GO


