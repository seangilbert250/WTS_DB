USE [WTS]
GO

ALTER TABLE [dbo].[UserSetting] DROP CONSTRAINT [FK_UserSetting_WTS_RESOURCE]
GO

ALTER TABLE [dbo].[UserSetting] DROP CONSTRAINT [FK_UserSetting_UserSettingType]
GO

/****** Object:  Table [dbo].[UserSetting]    Script Date: 9/9/2015 2:18:16 PM ******/
DROP TABLE [dbo].[UserSetting]
GO

/****** Object:  Table [dbo].[UserSetting]    Script Date: 9/9/2015 2:18:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UserSetting](
	[UserSettingID] [int] IDENTITY(1,1) NOT NULL,
	[WTS_RESOURCEID] [int] NOT NULL,
	[UserSettingTypeID] [int] NOT NULL,
	[GridNameID] [int] NULL,
	[SettingValue] [nvarchar](50) NOT NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[UserSettingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
    CONSTRAINT [FK_UserSetting_GridName] FOREIGN KEY ([GridNameID]) REFERENCES [GridName]([GridNameID])
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[UserSetting]  WITH CHECK ADD  CONSTRAINT [FK_UserSetting_UserSettingType] FOREIGN KEY([UserSettingTypeID])
REFERENCES [dbo].[UserSettingType] ([UserSettingTypeID])
GO

ALTER TABLE [dbo].[UserSetting] CHECK CONSTRAINT [FK_UserSetting_UserSettingType]
GO

ALTER TABLE [dbo].[UserSetting]  WITH CHECK ADD  CONSTRAINT [FK_UserSetting_WTS_RESOURCE] FOREIGN KEY([WTS_RESOURCEID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[UserSetting] CHECK CONSTRAINT [FK_UserSetting_WTS_RESOURCE]
GO

