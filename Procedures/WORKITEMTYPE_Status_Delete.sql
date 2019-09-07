USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WORKITEMTYPE_Status_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WORKITEMTYPE_Status_Delete]

GO

CREATE PROCEDURE [dbo].[WORKITEMTYPE_Status_Delete]
	@WORKITEMTYPE_StatusID int, 
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

		BEGIN
			SELECT @exists = COUNT(WORKITEMTYPE_StatusID)
				FROM WORKITEMTYPE_Status
				WHERE 
					WORKITEMTYPE_StatusID = @WORKITEMTYPE_StatusID;

				IF ISNULL(@exists,0) = 0
					RETURN;

				BEGIN TRY
					DELETE FROM WORKITEMTYPE_Status
					WHERE
						WORKITEMTYPE_StatusID = @WORKITEMTYPE_StatusID;

					SET @deleted = 1;
				END TRY
				BEGIN CATCH
					SET @deleted = 0;
				END CATCH;
		END;
END;
