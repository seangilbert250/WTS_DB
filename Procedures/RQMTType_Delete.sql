USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTType_Delete]    Script Date: 4/30/2018 10:42:59 AM ******/
DROP PROCEDURE [dbo].[RQMTType_Delete]
GO

/****** Object:  StoredProcedure [dbo].[RQMTType_Delete]    Script Date: 4/30/2018 10:42:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[RQMTType_Delete]
	@RQMTTypeID int,
	@exists int output,
	@hasDependencies int output,
	@deleted int output,
	@archived int output
AS
BEGIN
	SET @exists = 0;
	SET @hasDependencies = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(RQMTTypeID)
	FROM RQMTType
	WHERE
		RQMTTypeID = @RQMTTypeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM RQMTSetType WHERE RQMTTypeID = @RQMTTypeID;
	--SELECT @hasDependencies = COUNT(*) FROM EffortArea_Size WHERE EffortAreaID = @EffortAreaID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE RQMTType
			SET ARCHIVE = 1
			WHERE
				RQMTTypeID = @RQMTTypeID;

			SET @archived = 1;
			RETURN;
		END;
	ELSE
		BEGIN
			DELETE FROM RQMTType
			WHERE RQMTTypeID = @RQMTTypeID;

			SET @deleted = 1;
		END;

END;

GO


