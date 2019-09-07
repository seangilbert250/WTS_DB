USE WTS
GO

/****** Object:  Table [dbo].[User_Filter_Custom]    Script Date: 11/5/2015 12:00:00 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[User_Filter_Custom]') AND type in (N'U'))
DROP TABLE [dbo].[User_Filter_Custom]
GO

/****** Object:  Table [dbo].[User_Filter_Custom]    Script Date: 11/5/2015 12:00:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[User_Filter_Custom](
	[UserName] [nvarchar](255) NOT NULL,
	[CollectionName] [nvarchar](255) NOT NULL,
	[Module] [nvarchar](255) NOT NULL,
	[FilterName] [nvarchar](255) NOT NULL,
	[FilterID] [int] NOT NULL,
	[FilterText] [nvarchar](255) NOT NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate())
) ON [PRIMARY]

GO
