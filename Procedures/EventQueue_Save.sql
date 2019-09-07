USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[EventQueue_Save]    Script Date: 1/22/2018 2:13:50 PM ******/
DROP PROCEDURE [dbo].[EventQueue_Save]
GO

/****** Object:  StoredProcedure [dbo].[EventQueue_Save]    Script Date: 1/22/2018 2:13:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[EventQueue_Save]
(
	@EventQueueID BIGINT = 0 OUTPUT,
	@EVENT_TYPEID INT,
	@EVENT_STATUSID INT,
	@ScheduledDate DATETIME,			
	@CompletedDate DATETIME = NULL,	
	@Payload NVARCHAR(MAX) = NULL,
	@CreatedBy NVARCHAR(255) = NULL,
	@CreatedDate DATETIME = NULL,	
	@Result NVARCHAR(MAX) = NULL,
	@Error NVARCHAR(MAX) = NULL
)

AS

IF @EventQueueID = 0
BEGIN
	INSERT INTO [dbo].[EventQueue]
           ([EVENT_TYPEID]
           ,[EVENT_STATUSID]
           ,[ScheduledDate]
           ,[CompletedDate]
           ,[Payload]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[Result]
           ,[Error])
     VALUES
			(@EVENT_TYPEID,
			@EVENT_STATUSID,
			@ScheduledDate,			
			@CompletedDate,	
			@Payload,
			@CreatedBy,
			@CreatedDate,	
			@Result,
			@Error)

	SELECT @EventQueueID = SCOPE_IDENTITY()
END
ELSE
BEGIN
	UPDATE [dbo].[EventQueue]
	   SET 
		  [EVENT_TYPEID] = @EVENT_TYPEID,
		  [EVENT_STATUSID] = @EVENT_STATUSID,
		  [ScheduledDate] = @ScheduledDate,
		  [CompletedDate] = @CompletedDate,
		  [Payload] = @Payload,
		  [CreatedBy] = @CreatedBy,
		  [CreatedDate] = @CreatedDate,
		  [Result] = @Result,
		  [Error] = @Error
	 WHERE EventQueueID = @EventQueueID
END
GO


