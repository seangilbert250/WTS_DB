USE [WTS]
GO

/****** Object:  Table [dbo].[ReleaseSchedule]    Script Date: 2/16/2018 3:18:33 PM ******/
IF dbo.TableExists('dbo', 'ReleaseSchedule') = 1
	DROP TABLE [dbo].[ReleaseSchedule]
GO

/****** Object:  Table [dbo].[ReleaseSchedule]    Script Date: 2/16/2018 3:18:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ReleaseSchedule](
	[ReleaseScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[ReleaseScheduleDeliverable] [nvarchar](50) NOT NULL,
	[ProductVersionID] [int] NOT NULL,
	[Description] [nvarchar](500) NULL,
	[PlannedStart] [date] NULL,
	[PlannedEnd] [date] NULL,
	[PlannedInvStart] [date] NULL,
	[PlannedInvEnd] [date] NULL,
	[PlannedTDStart] [date] NULL,
	[PlannedTDEnd] [date] NULL,
	[PlannedCDStart] [date] NULL,
	[PlannedCDEnd] [date] NULL,
	[PlannedCodingStart] [date] NULL,
	[PlannedCodingEnd] [date] NULL,
	[PlannedITStart] [date] NULL,
	[PlannedITEnd] [date] NULL,
	[PlannedCVTStart] [date] NULL,
	[PlannedCVTEnd] [date] NULL,
	[PlannedAdoptStart] [date] NULL,
	[PlannedAdoptEnd] [date] NULL,
	[ARCHIVE] [bit] NOT NULL,
	[CREATEDBY] [nvarchar](255) NOT NULL,
	[CREATEDDATE] [datetime] NOT NULL,
	[UPDATEDBY] [nvarchar](255) NOT NULL,
	[UPDATEDDATE] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReleaseScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ReleaseSchedule] ADD  DEFAULT ((0)) FOR [ARCHIVE]
GO

ALTER TABLE [dbo].[ReleaseSchedule] ADD  DEFAULT ('WTS_ADMIN') FOR [CREATEDBY]
GO

ALTER TABLE [dbo].[ReleaseSchedule] ADD  DEFAULT (getdate()) FOR [CREATEDDATE]
GO

ALTER TABLE [dbo].[ReleaseSchedule] ADD  DEFAULT ('WTS_ADMIN') FOR [UPDATEDBY]
GO

ALTER TABLE [dbo].[ReleaseSchedule] ADD  DEFAULT (getdate()) FOR [UPDATEDDATE]
GO


