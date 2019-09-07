USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_WorkActivity_Update]    Script Date: 3/29/2018 4:58:54 PM ******/
DROP PROCEDURE [dbo].[WTS_System_WorkActivity_Update]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_WorkActivity_Update]    Script Date: 3/29/2018 4:58:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WTS_System_WorkActivity_Update]
	@WTS_SYSTEMID int,
	@WTS_SYSTEM_WORKACTIVITYID int,
	@WORKITEMTYPEID int,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@WTS_SYSTEM_WORKACTIVITYID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WTS_SYSTEM_WORKACTIVITY WHERE WTS_SYSTEM_WORKACTIVITYID = @WTS_SYSTEM_WORKACTIVITYID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--Check for duplicate
					SELECT @count = COUNT(*) FROM WTS_SYSTEM_WORKACTIVITY
					WHERE WTS_SYSTEMID = @WTS_SYSTEMID
						AND WORKITEMTYPEID = @WORKITEMTYPEID
						AND WTS_SYSTEM_WORKACTIVITYID != @WTS_SYSTEM_WORKACTIVITYID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE WTS_SYSTEM_WORKACTIVITY
					SET
						WORKITEMTYPEID = @WORKITEMTYPEID
						, WTS_SYSTEMID = @WTS_SYSTEMID
						, Archive = @Archive
						, UpdatedBy = @UpdatedBy
						, UpdatedDate = @date
					WHERE
						WTS_SYSTEM_WORKACTIVITYID = @WTS_SYSTEM_WORKACTIVITYID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
