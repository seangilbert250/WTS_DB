USE [WTS]
GO
/****** Object:  Table [dbo].[SREMAIL]    Script Date: 4/26/2017 3:23:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SREMAIL]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SREMAIL](
	[SRID] [int] NULL,
	[PARENT_SRID] [int] NULL,
	[SUBJECT] [nvarchar](max) NULL,
	[BODY] [nvarchar](max) NULL,
	[WEBSYSTEM] [nchar](500) NULL,
	[TYPE] [nchar](500) NULL,
	[TOPICKEYWORD] [nchar](500) NULL,
	[STATUS] [nchar](500) NULL,
	[PRIORITY] [nchar](500) NULL,
	[CREATEDDATE] [datetime] NULL,
	[SUBMITTEDBY] [nchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
