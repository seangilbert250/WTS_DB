USE [WTS]
GO

/****** Object:  Table [dbo].[RQMTComplexity]    Script Date: 6/21/2018 2:49:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RQMTComplexity](
	[RQMTComplexityID] [int] IDENTITY(1,1) NOT NULL,
	[RQMTComplexity] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[Points] [int] NULL,
	[Sort] [int] NULL,
	[Archive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[UpdatedBy] [nvarchar](255) NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RQMTComplexity] PRIMARY KEY CLUSTERED 
(
	[RQMTComplexityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_RQMTComplexity] UNIQUE NONCLUSTERED 
(
	[RQMTComplexity] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[RQMTComplexity] ADD  DEFAULT ((0)) FOR [Sort]
GO

ALTER TABLE [dbo].[RQMTComplexity] ADD  DEFAULT ((0)) FOR [Archive]
GO

ALTER TABLE [dbo].[RQMTComplexity] ADD  DEFAULT ('WTS') FOR [CreatedBy]
GO

ALTER TABLE [dbo].[RQMTComplexity] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [dbo].[RQMTComplexity] ADD  DEFAULT ('WTS') FOR [UpdatedBy]
GO

ALTER TABLE [dbo].[RQMTComplexity] ADD  DEFAULT (getdate()) FOR [UpdatedDate]
GO


