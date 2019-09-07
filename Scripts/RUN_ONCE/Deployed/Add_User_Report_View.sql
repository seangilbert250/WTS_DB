USE [WTS]
GO

/****** Object:  Table [dbo].[User_Report_View]    Script Date: 2/6/2018 10:58:48 AM ******/
IF dbo.TableExists('dbo', 'User_Report_View') = 1
	DROP TABLE [dbo].[User_Report_View]
GO

/****** Object:  Table [dbo].[User_Report_View]    Script Date: 2/6/2018 10:58:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[User_Report_View](
	[UserReportViewID] [int] NOT NULL,
	[ViewName] [nvarchar](255) NOT NULL,
	[WTS_RESOURCEID] [int] NOT NULL,
	[ReportTypeID] [int] NOT NULL,
	[ReportParameters] [nvarchar](max) NOT NULL,
	[ReportLevels] [nvarchar](max) NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL,
	[CREATEDDATE] [datetime] NOT NULL,
	[UPDATEDBY] [nvarchar](255) NOT NULL,
	[UPDATEDDATE] [datetime] NOT NULL,
 CONSTRAINT [PK_User_Report_View] PRIMARY KEY CLUSTERED 
(
	[UserReportViewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

create index IDX_User_Report_View_Resource on dbo.User_Report_View(WTS_RESOURCEID, ReportTypeID)
go

ALTER TABLE dbo.User_Report_View
ADD FOREIGN KEY (WTS_RESOURCEID) REFERENCES WTS_RESOURCE(WTS_RESOURCEID)
	ON DELETE CASCADE
go