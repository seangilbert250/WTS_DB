USE WTS
GO

EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'THEME', @level2type=N'COLUMN',@level2name=N'ARCHIVE'

GO

/****** Object:  Table [dbo].[THEME]    Script Date: 7/2/2015 1:57:29 PM ******/
DROP TABLE [dbo].[THEME]
GO

/****** Object:  Table [dbo].[THEME]    Script Date: 7/2/2015 1:57:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[THEME](
	[THEMEID] [int] IDENTITY(1,1) NOT NULL,
	[THEME] [nvarchar](50) NOT NULL,
	[DESCRIPTION] [text] NULL,
	[ARCHIVE] [bit] NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NULL DEFAULT (getdate()),
 CONSTRAINT [PK_THEME] PRIMARY KEY CLUSTERED 
(
	[THEMEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Archive this record? 0 = no, 1 = yes(archived)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'THEME', @level2type=N'COLUMN',@level2name=N'ARCHIVE'
GO

