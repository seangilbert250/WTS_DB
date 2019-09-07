USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[RequestGroup_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [RequestGroup_Delete]

GO

CREATE PROCEDURE [dbo].[RequestGroup_Delete]
	@RequestGroupID int, 
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

	SELECT @exists = COUNT(*)
	FROM RequestGroup
	WHERE 
		RequestGroupID = @RequestGroupID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKREQUEST WHERE RequestGroupID = @RequestGroupID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE RequestGroup
			SET ARCHIVE = 1
			WHERE
				RequestGroupID = @RequestGroupID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM RequestGroup
		WHERE
			RequestGroupID = @RequestGroupID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
