USE WTS
GO

ALTER TABLE [dbo].[Attribute] DROP CONSTRAINT [FK_Attribute_AttributeType]
GO

ALTER TABLE [dbo].[Attribute] DROP CONSTRAINT [DF__Attribute__UPDAT__14F1071C]
GO

ALTER TABLE [dbo].[Attribute] DROP CONSTRAINT [DF__Attribute__UPDAT__13FCE2E3]
GO

ALTER TABLE [dbo].[Attribute] DROP CONSTRAINT [DF__Attribute__CREAT__1308BEAA]
GO

ALTER TABLE [dbo].[Attribute] DROP CONSTRAINT [DF__Attribute__CREAT__12149A71]
GO

ALTER TABLE [dbo].[Attribute] DROP CONSTRAINT [DF__Attribute__Archi__11207638]
GO

/****** Object:  Table [dbo].[Attribute]    Script Date: 7/16/2015 2:02:00 PM ******/
DROP TABLE [dbo].[Attribute]
GO

/****** Object:  Table [dbo].[Attribute]    Script Date: 7/16/2015 2:02:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Attribute](
	[AttributeId] [int] IDENTITY(1,1) NOT NULL,
	[AttributeTypeId] [int] NOT NULL,
	[Attribute] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[Archive] [bit] NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[AttributeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Attribute]  WITH CHECK ADD  CONSTRAINT [FK_Attribute_AttributeType] FOREIGN KEY([AttributeTypeId])
REFERENCES [dbo].[AttributeType] ([AttributeTypeId])
GO

ALTER TABLE [dbo].[Attribute] CHECK CONSTRAINT [FK_Attribute_AttributeType]
GO

