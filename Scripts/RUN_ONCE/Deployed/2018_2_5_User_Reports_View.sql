USE [WTS]
GO

/****** Object:  Table [dbo].[User_Report_View]    Script Date: 2/2/2018 4:05:12 PM ******/
DROP TABLE [dbo].[User_Report_View]
GO

/****** Object:  Table [dbo].[User_Report_View]    Script Date: 2/2/2018 4:05:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[User_Report_View](
	[UserName] [nvarchar](255) NOT NULL,
	[ViewName] [nvarchar](255) NOT NULL,
	[ReportTypeID] [int] NOT NULL,
	[ReportParameters] [nvarchar](max) NOT NULL,
	[ReportLevels] [nvarchar](max),
	[CREATEDBY] [nvarchar](255) NOT NULL,
	[CREATEDDATE] [datetime] NOT NULL,
	[UPDATEDBY] [nvarchar](255) NOT NULL,
	[UPDATEDDATE] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


