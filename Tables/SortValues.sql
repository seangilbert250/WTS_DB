USE [WTS]
GO
/****** Object:  Table [dbo].[SortValues]    Script Date: 4/26/2017 3:23:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SortValues]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SortValues](
	[SessionID] [nchar](100) NOT NULL,
	[UserName] [nchar](255) NOT NULL,
	[GridNameID] [int] NULL,
	[GridName] [nchar](255) NULL,
	[sortValues] [nchar](255) NOT NULL
) ON [PRIMARY]
END
GO
