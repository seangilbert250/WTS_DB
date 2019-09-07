USE [WTS]
GO

ALTER TABLE [dbo].[RQMTSystem] ADD RQMTAccepted_By [nvarchar](255) NULL
GO

ALTER TABLE [dbo].[RQMTSystem] ADD RQMTAccepted_Date [datetime] NULL
GO