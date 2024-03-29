USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[Effort_Update]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Effort_Update]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Effort_Update]
GO
/****** Object:  StoredProcedure [dbo].[Effort_Update]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Effort_Update]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[Effort_Update] AS' 
END
GO

ALTER PROCEDURE [dbo].[Effort_Update]
	@EffortID int,
	@Effort nvarchar(50),
	@Description nvarchar(500) = null,
	@Sort_Order int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	IF ISNULL(@EffortID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM Effort WHERE EffortID = @EffortID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE Effort
					SET
						Effort = @Effort
						, [DESCRIPTION] = @Description
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						EffortID = @EffortID;
					
					SET @saved = 1; 
				END;
		END;
END;


GO
