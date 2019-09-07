﻿USE WTS
GO

/****** Object:  Table [dbo].[WTS_SYSTEM]    Script Date: 7/2/2015 2:02:37 PM ******/
DROP TABLE [dbo].[WTS_SYSTEM]
GO

/****** Object:  Table [dbo].[WTS_SYSTEM]    Script Date: 7/2/2015 2:02:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WTS_SYSTEM](
	[WTS_SYSTEMID] [int] IDENTITY(1,1) NOT NULL,
	[WTS_SYSTEM] [nvarchar](2000) NOT NULL,
	[DESCRIPTION] [nvarchar](2000) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[WTS_SYSTEMID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

