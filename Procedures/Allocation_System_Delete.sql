USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_System_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_System_Delete]

GO

CREATE PROCEDURE [dbo].[Allocation_System_Delete]
	@Allocation_SystemID int, 
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(Allocation_SystemID)
	FROM Allocation_System
	WHERE 
		Allocation_SystemID = @Allocation_SystemID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		DELETE FROM Allocation_System
		WHERE
			Allocation_SystemID = @Allocation_SystemID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;
END;

GO
