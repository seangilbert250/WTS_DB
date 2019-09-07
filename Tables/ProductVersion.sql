USE WTS
GO

/****** Object:  Table [dbo].[ProductVersion]    Script Date: 7/2/2015 1:58:44 PM ******/
DROP TABLE [dbo].[ProductVersion]
GO

/****** Object:  Table [dbo].[ProductVersion]    Script Date: 7/2/2015 1:58:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductVersion](
	[ProductVersionID] [int] IDENTITY(1,1) NOT NULL,
	[ProductVersion] [nvarchar](50) NOT NULL,
	[DefaultSelection] [bit] NULL DEFAULT ((0)),
	[Description] [nvarchar](500) NULL,
	[Narrative] [nvarchar](max) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[StatusID] INT NULL,
    [StartDate] [datetime] null,
    [EndDate] [datetime] null,
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
    PRIMARY KEY CLUSTERED
(
	[ProductVersionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
    CONSTRAINT [FK_ProductVersion_Status] FOREIGN KEY ([StatusID]) REFERENCES [Status]([StatusID])
) ON [PRIMARY]

GO

