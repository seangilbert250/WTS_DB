USE WTS
GO

/****** Object:  Table [dbo].[WorkArea]    Script Date: 7/2/2015 1:49:23 PM ******/
DROP TABLE [dbo].[WorkArea]
GO

/****** Object:  Table [dbo].[WorkArea]    Script Date: 7/2/2015 1:49:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[WorkArea](
	[WorkAreaID] [int] IDENTITY(1,1) NOT NULL,
	[WorkArea] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[ProposedPriorityRank] [int] NULL,
	[ActualPriorityRank] [int] NULL,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[WorkAreaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

