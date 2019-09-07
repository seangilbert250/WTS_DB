USE WTS
GO

ALTER TABLE [dbo].[Resource_Certification] DROP CONSTRAINT [FK_Resource_Certification_WTS_RESOURCE]
GO

/****** Object:  Table [dbo].[Resource_Certification]    Script Date: 7/15/2015 2:18:43 PM ******/
DROP TABLE [dbo].[Resource_Certification]
GO

/****** Object:  Table [dbo].[Resource_Certification]    Script Date: 7/15/2015 2:18:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Resource_Certification](
	[Resource_CertificationId] [int] IDENTITY(1,1) NOT NULL,
	[WTS_RESOURCEID] [int] NOT NULL,
	[Resource_Certification] [nvarchar](150) NOT NULL,
	[Description] [nchar](500) NULL,
	[Expiration_Date] [date] NULL,
	[Expired] [bit] NULL DEFAULT 0,
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[Resource_CertificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Resource_Certification]  WITH CHECK ADD  CONSTRAINT [FK_Resource_Certification_WTS_RESOURCE] FOREIGN KEY([WTS_RESOURCEID])
REFERENCES [dbo].[WTS_RESOURCE] ([WTS_RESOURCEID])
GO

ALTER TABLE [dbo].[Resource_Certification] CHECK CONSTRAINT [FK_Resource_Certification_WTS_RESOURCE]
GO

