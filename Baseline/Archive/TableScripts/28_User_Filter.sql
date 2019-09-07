USE WTS
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__User_Filt__Creat__53F76C67]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[User_Filter] DROP CONSTRAINT [DF__User_Filt__Creat__53F76C67]
END

GO

/****** Object:  Table [dbo].[User_Filter]    Script Date: 07/27/2015 15:48:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[User_Filter]') AND type in (N'U'))
DROP TABLE [dbo].[User_Filter]
GO

/****** Object:  Table [dbo].[User_Filter]    Script Date: 07/27/2015 15:48:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[User_Filter](
	[SessionID] [nvarchar](100) NULL,
	[UserName] [nvarchar](100) NULL,
	[FilterID] [int] NULL,
	[FilterType] [int] NULL,
	[CreatedDate] [datetime] NULL DEFAULT (getdate())
) ON [PRIMARY]

GO
