USE [WTS]
GO

ALTER TABLE [dbo].[UserSettingType] DROP CONSTRAINT [DF__UserSetti__ARCHI__35C7EB02]
GO

/****** Object:  Table [dbo].[UserSettingType]    Script Date: 9/9/2015 2:14:21 PM ******/
DROP TABLE [dbo].[UserSettingType]
GO

/****** Object:  Table [dbo].[UserSettingType]    Script Date: 9/9/2015 2:14:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UserSettingType](
	[UserSettingTypeID] [int] IDENTITY(1,1) NOT NULL,
	[UserSettingType] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[ARCHIVE] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserSettingTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[UserSettingType] ADD  DEFAULT ((0)) FOR [ARCHIVE]
GO

