exec sp_rename 'RQMTDescriptionRQMTSystem','RQMTSystemRQMTDescription';

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
EXECUTE sp_rename N'dbo.RQMTSystemRQMTDescription.RQMTDescriptionRQMTSystemID', N'Tmp_RQMTSystemRQMTDescriptionID', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.RQMTSystemRQMTDescription.Tmp_RQMTSystemRQMTDescriptionID', N'RQMTSystemRQMTDescriptionID', 'COLUMN' 
GO
ALTER TABLE dbo.RQMTSystemRQMTDescription SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
 
 
 
 
 
 
 USE [WTS]
GO

/****** Object:  Index [PK_RQMTSystemRQMTDescription]    Script Date: 4/6/2018 12:01:07 PM ******/
ALTER TABLE [dbo].[RQMTSystemRQMTDescription] DROP CONSTRAINT [PK_RQMTDescriptionRQMTSystem] WITH ( ONLINE = OFF )
GO

/****** Object:  Index [PK_RQMTSystemRQMTDescription]    Script Date: 4/6/2018 12:01:07 PM ******/
ALTER TABLE [dbo].[RQMTSystemRQMTDescription] ADD  CONSTRAINT [PK_RQMTSystemRQMTDescription] PRIMARY KEY CLUSTERED 
(
	[RQMTSystemRQMTDescriptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
 
 
 
 
 
 
 
 USE [WTS]
GO

ALTER TABLE [dbo].[RQMTSystemRQMTDescription] DROP CONSTRAINT [FK_RQMTDescriptionRQMTSystem_RQMTDescription]
GO

ALTER TABLE [dbo].[RQMTSystemRQMTDescription]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSystemRQMTDescription_RQMTDescription] FOREIGN KEY([RQMTDescriptionID])
REFERENCES [dbo].[RQMTDescription] ([RQMTDescriptionID])
GO

ALTER TABLE [dbo].[RQMTSystemRQMTDescription] CHECK CONSTRAINT [FK_RQMTSystemRQMTDescription_RQMTDescription]
GO



USE [WTS]
GO

ALTER TABLE [dbo].[RQMTSystemRQMTDescription] DROP CONSTRAINT [FK_RQMTDescriptionRQMTSystem_RQMTSystem]
GO

ALTER TABLE [dbo].[RQMTSystemRQMTDescription]  WITH CHECK ADD  CONSTRAINT [FK_RQMTSystemRQMTDescription_RQMTSystem] FOREIGN KEY([RQMTSystemID])
REFERENCES [dbo].[RQMTSystem] ([RQMTSystemID])
GO

ALTER TABLE [dbo].[RQMTSystemRQMTDescription] CHECK CONSTRAINT [FK_RQMTSystemRQMTDescription_RQMTSystem]
GO

USE [WTS]
GO

/****** Object:  Index [UK_RQMTDescriptionRQMTSystem]    Script Date: 4/6/2018 12:03:45 PM ******/
ALTER TABLE [dbo].[RQMTSystemRQMTDescription] DROP CONSTRAINT [UK_RQMTDescriptionRQMTSystem]
GO

/****** Object:  Index [UK_RQMTDescriptionRQMTSystem]    Script Date: 4/6/2018 12:03:45 PM ******/
ALTER TABLE [dbo].[RQMTSystemRQMTDescription] ADD  CONSTRAINT [UK_RQMTSystemRQMTDescription] UNIQUE NONCLUSTERED 
(
	[RQMTDescriptionID] ASC,
	[RQMTSystemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO