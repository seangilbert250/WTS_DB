﻿USE WTS
GO

ALTER TABLE [dbo].[STATUS_PHASE] DROP CONSTRAINT [FK_STATUS_PHASE_STATUS]
GO

ALTER TABLE [dbo].[STATUS_PHASE] DROP CONSTRAINT [FK_STATUS_PHASE_PDDTDR_PHASE]
GO

/****** Object:  Table [dbo].[STATUS_PHASE]    Script Date: 7/2/2015 1:50:01 PM ******/
DROP TABLE [dbo].[STATUS_PHASE]
GO

/****** Object:  Table [dbo].[STATUS_PHASE]    Script Date: 7/2/2015 1:50:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[STATUS_PHASE](
	[STATUS_PHASEID] [int] IDENTITY(1,1) NOT NULL,
	[STATUSID] [int] NOT NULL,
	[PDDTDR_PHASEID] [int] NOT NULL,
	[DESCRIPTION] [nvarchar](255) NULL,
	[SORT_ORDER] [int] NULL DEFAULT ((99)),
	[ARCHIVE] [bit] NOT NULL DEFAULT ((0)),
	[CREATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[CREATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
	[UPDATEDBY] [nvarchar](255) NOT NULL DEFAULT ('WTS_ADMIN'),
	[UPDATEDDATE] [datetime] NOT NULL DEFAULT (getdate()),
PRIMARY KEY CLUSTERED 
(
	[STATUS_PHASEID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[STATUS_PHASE]  WITH CHECK ADD  CONSTRAINT [FK_STATUS_PHASE_PDDTDR_PHASE] FOREIGN KEY([PDDTDR_PHASEID])
REFERENCES [dbo].[PDDTDR_PHASE] ([PDDTDR_PHASEID])
GO

ALTER TABLE [dbo].[STATUS_PHASE] CHECK CONSTRAINT [FK_STATUS_PHASE_PDDTDR_PHASE]
GO

ALTER TABLE [dbo].[STATUS_PHASE]  WITH CHECK ADD  CONSTRAINT [FK_STATUS_PHASE_STATUS] FOREIGN KEY([STATUSID])
REFERENCES [dbo].[STATUS] ([STATUSID])
GO

ALTER TABLE [dbo].[STATUS_PHASE] CHECK CONSTRAINT [FK_STATUS_PHASE_STATUS]
GO

