USE [WTS]
GO

ALTER TABLE [dbo].[News] ADD [Start_Date] DATE NULL DEFAULT (getdate()) WITH VALUES
GO

ALTER TABLE [dbo].[News] ADD [End_Date] DATE NULL DEFAULT (getdate()) WITH VALUES
GO

ALTER TABLE [dbo].[News] ADD [Bln_Active] INT DEFAULT ((0))
GO

ALTER TABLE [dbo].[News] ADD [Bln_News] INT DEFAULT ((0))
GO

ALTER TABLE [dbo].[News] ADD [Time_Zone] NVARCHAR(4) DEFAULT ('EST') 
GO

ALTER TABLE [dbo].[News] ADD [Created_By] NVARCHAR(255) NULL DEFAULT ('WTS_ADMIN')
GO

ALTER TABLE [dbo].[News] ADD [Created_Date] DATE NULL DEFAULT (getdate()) WITH VALUES
GO

ALTER TABLE [dbo].[News] ADD [Updated_By] NVARCHAR(255) NULL DEFAULT ('WTS_ADMIN')
GO

ALTER TABLE [dbo].[News] ADD [Updated_Date] DATE NULL DEFAULT (getdate()) WITH VALUES 
GO

ALTER TABLE [dbo].[News] ADD [Bln_Archive] INT DEFAULT ((0))
GO
