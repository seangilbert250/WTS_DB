USE [WTS]
GO

/****** Object:  Table [dbo].[AllocationGroup]    Script Date: 7/18/2016 12:06:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WTS_SYSTEM_SUITE](
	[WTS_SYSTEM_SUITEID] [int] IDENTITY(1,1) NOT NULL,
	[WTS_SYSTEM_SUITE] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NULL,
	[SORTORDER] [int] NULL DEFAULT ((0)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [PK_WTS_SYSTEM_SUITEID] PRIMARY KEY CLUSTERED 
(
	[WTS_SYSTEM_SUITEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE WTS_SYSTEM
ADD WTS_SYSTEM_SUITEID INT NULL
	CONSTRAINT [FK_WTS_SYSTEMID] FOREIGN KEY ([WTS_SYSTEM_SUITEID]) REFERENCES [WTS_SYSTEM_SUITE] ([WTS_SYSTEM_SUITEID])

