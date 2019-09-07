USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ItemType_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ItemType_Delete]

GO

CREATE PROCEDURE [dbo].[ItemType_Delete]
	@TypeID int, 
	@exists int output,
	@deleted int output,
	@hasDependencies int output,
	@archived int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;
	SET @archived = 0;
	SET @hasDependencies = 0;
	
	SELECT @exists = COUNT(WORKITEMTYPE)
	FROM WORKITEMTYPE
	WHERE 
	WORKITEMTYPEID = @TypeID;

	IF ISNULL(@exists,0) = 0
	RETURN;

	SELECT @hasDependencies = COUNT(*) FROM WORKITEM WHERE WORKITEMTYPEID = @TypeID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE WORKITEMTYPE
			SET ARCHIVE = 1
			WHERE
				WORKITEMTYPEID = @TypeID;

			SET @archived = 1;
			RETURN;
		END;

	BEGIN TRY
		DELETE FROM WORKITEMTYPE
		WHERE
			WORKITEMTYPEID = @TypeID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH
END

