USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AORType_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AORType_Delete]

GO

Create PROCEDURE [dbo].[AORType_Delete]
	@AORWorkTypeID int, 
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

	SELECT @exists = COUNT(AORWorkTypeID)
	FROM AORWorkType
	WHERE 
		AORWorkTypeID = @AORWorkTypeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	--SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE EffortAreaID = @EffortAreaID;
	--SELECT @hasDependencies = COUNT(*) FROM WORKITEM_TASK WHERE EffortAreaID = @EffortAreaID;
	--SELECT @hasDependencies = COUNT(*) FROM EffortArea_Size WHERE EffortAreaID = @EffortAreaID;

	--IF ISNULL(@hasDependencies,0) > 0
	--	BEGIN
	--		--archive the user instead
	--		UPDATE EffortArea
	--		SET ARCHIVE = 1
	--		WHERE
	--			EffortAreaID = @EffortAreaID;

	--		SET @archived = 1;
	--		RETURN;
	--	END;

	BEGIN TRY
		UPDATE AORRelease SET AORWorkTypeID = null 
			WHERE AORWorkTypeID = @AORWorkTypeID;

		DELETE FROM AORWorkType
			WHERE AORWorkTypeID = @AORWorkTypeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
