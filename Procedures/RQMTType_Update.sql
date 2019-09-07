USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTType_Update]    Script Date: 7/6/2018 1:56:49 PM ******/
DROP PROCEDURE [dbo].[RQMTType_Update]
GO

/****** Object:  StoredProcedure [dbo].[RQMTType_Update]    Script Date: 7/6/2018 1:56:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[RQMTType_Update]
	@RQMTTypeID int,
	@RQMTType nvarchar(150),
	@Description nvarchar(500) = null,
	@Sort int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved int output,
	@Internal bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@RQMTTypeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM RQMTType WHERE RQMTTypeID = @RQMTTypeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					SELECT @count = COUNT(*) FROM RQMTType
					WHERE RQMTType = @RQMTType
						AND RQMTTypeID != @RQMTTypeID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							SET @saved = 0;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE RQMTType
					SET
						RQMTType = @RQMTType
						, [Description] = @Description
						, SORT = @Sort
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
						, Internal = @Internal
					WHERE
						RQMTTypeID = @RQMTTypeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO


