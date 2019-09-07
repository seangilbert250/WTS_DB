﻿USE WTS
GO

ALTER TABLE [dbo].[PASSWORD_QUESTION] DROP CONSTRAINT [DF__PASSWORD___ARCHI__3BCADD1B]
GO

/****** Object:  Table [dbo].[PASSWORD_QUESTION]    Script Date: 6/12/2015 4:10:37 PM ******/
DROP TABLE [dbo].[PASSWORD_QUESTION]
GO

/****** Object:  Table [dbo].[PASSWORD_QUESTION]    Script Date: 6/12/2015 4:10:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PASSWORD_QUESTION](
	[PASSWORD_QUESTIONID] [int] IDENTITY(1,1) NOT NULL,
	[PASSWORD_QUESTION] [nvarchar](255) NOT NULL,
	[ARCHIVE] [bit] NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[PASSWORD_QUESTIONID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

