USE [WTS]
GO

/****** Object:  Table [dbo].[ContractType]    Script Date: 8/13/2015 11:29:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ContractType](
	[ContractTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ContractType] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[Archive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ContractTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ContractType] ADD  DEFAULT ((0)) FOR [Archive]
GO

