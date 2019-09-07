USE WTS
GO

ALTER TABLE [dbo].[AttributeType] DROP CONSTRAINT [DF__Attribute__UPDAT__05AEC38C]
GO

ALTER TABLE [dbo].[AttributeType] DROP CONSTRAINT [DF__Attribute__UPDAT__04BA9F53]
GO

ALTER TABLE [dbo].[AttributeType] DROP CONSTRAINT [DF__Attribute__CREAT__03C67B1A]
GO

ALTER TABLE [dbo].[AttributeType] DROP CONSTRAINT [DF__Attribute__CREAT__02D256E1]
GO

ALTER TABLE [dbo].[AttributeType] DROP CONSTRAINT [DF__Attribute__Archi__01DE32A8]
GO

/****** Object:  Table [dbo].[AttributeType]    Script Date: 7/16/2015 2:01:48 PM ******/
DROP TABLE [dbo].[AttributeType]
GO

/****** Object:  Table [dbo].[AttributeType]    Script Date: 7/16/2015 2:01:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AttributeType](
	[AttributeTypeId] [int] IDENTITY(1,1) NOT NULL,
	[AttributeType] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[Archive] [bit] NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[AttributeTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
