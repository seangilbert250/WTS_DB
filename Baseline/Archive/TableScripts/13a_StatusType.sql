﻿USE WTS
GO

/****** Object:  Table [dbo].[StatusType]    Script Date: 7/2/2015 1:48:19 PM ******/
DROP TABLE [dbo].[StatusType]
GO

/****** Object:  Table [dbo].[StatusType]    Script Date: 7/2/2015 1:48:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[StatusType](
	[StatusTypeID] [int] IDENTITY(1,1) NOT NULL,
	[StatusType] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](255) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[StatusTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

