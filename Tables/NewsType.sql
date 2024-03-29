USE [WTS]
GO

/****** Object:  Table [dbo].[NewsType]    Script Date: 10/1/2018 3:30:58 PM ******/
DROP TABLE [dbo].[NewsType]
GO

/****** Object:  Table [dbo].[NewsType]    Script Date: 10/1/2018 3:30:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[NewsType](
	[NewsTypeID] [int] IDENTITY(1,1) NOT NULL,
	[NewsType] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[NewsTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



