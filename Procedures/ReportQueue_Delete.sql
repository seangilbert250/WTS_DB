USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_Delete]    Script Date: 1/22/2018 2:14:32 PM ******/
DROP PROCEDURE [dbo].[ReportQueue_Delete]
GO

/****** Object:  StoredProcedure [dbo].[ReportQueue_Delete]    Script Date: 1/22/2018 2:14:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ReportQueue_Delete]
(
	@ReportQueueID BIGINT
)

AS

DELETE FROM ReportQueue WHERE ReportQueueID = @ReportQueueID
GO


