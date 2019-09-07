USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Get]    Script Date: 2/14/2018 2:51:02 PM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Stage_Get]
GO

USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Add]    Script Date: 2/14/2018 2:51:02 PM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Stage_Add]
GO

/****** Object:  StoredProcedure [dbo].[Release_Schedule_StageList_Get]    Script Date: 2/14/2018 2:53:24 PM ******/
DROP PROCEDURE [dbo].[Release_Schedule_StageList_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_Stage_Update]    Script Date: 2/14/2018 2:54:04 PM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_Stage_Update]
GO

/****** Object:  StoredProcedure [dbo].[AORStage_Delete]    Script Date: 2/14/2018 2:57:33 PM ******/
DROP PROCEDURE [dbo].[AORStage_Delete]
GO

/****** Object:  StoredProcedure [dbo].[AORStageList_Get]    Script Date: 2/14/2018 2:58:53 PM ******/
DROP PROCEDURE [dbo].[AORStageList_Get]
GO

IF dbo.TableExists('dbo', 'AORReleaseStage') = 1
	ALTER TABLE [dbo].[AORReleaseStage] DROP CONSTRAINT [FK_AORReleaseStage_ReleaseSchedule]
GO

IF dbo.TableExists('dbo', 'AORReleaseStage') = 1
	ALTER TABLE [dbo].[AORReleaseStage] DROP CONSTRAINT [FK_AORReleaseStage_AORRelease]
GO

/****** Object:  Table [dbo].[AORReleaseStage]    Script Date: 2/14/2018 2:59:50 PM ******/
IF dbo.TableExists('dbo', 'AORReleaseStage') = 1
	DROP TABLE [dbo].[AORReleaseStage]
GO