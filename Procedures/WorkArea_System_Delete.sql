USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkArea_System_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WorkArea_System_Delete
GO

CREATE PROCEDURE [dbo].[WorkArea_System_Delete]
	@WorkArea_SystemID int, 
	@CV nvarchar(1),
	@exists int output,
	@deleted int output
AS
BEGIN
	SET @exists = 0;
	SET @deleted = 0;

	IF @CV = 0
		BEGIN
			SELECT @exists = COUNT(WorkArea_SystemID)
				FROM WorkArea_System
				WHERE 
					WorkArea_SystemID = @WorkArea_SystemID;

				IF ISNULL(@exists,0) = 0
					RETURN;

				BEGIN TRY
					DELETE FROM WorkArea_System
					WHERE
						WorkArea_SystemID = @WorkArea_SystemID;

					SET @deleted = 1;
				END TRY
				BEGIN CATCH
					SET @deleted = 0;
				END CATCH;
		END;
	ELSE
		BEGIN
			SELECT @exists = COUNT(Allocation_SystemId)
				FROM Allocation_System
				WHERE 
					Allocation_SystemId = @WorkArea_SystemID;

				IF ISNULL(@exists,0) = 0
					RETURN;

				BEGIN TRY
					DELETE FROM Allocation_System
					WHERE
						Allocation_SystemId = @WorkArea_SystemID;

					SET @deleted = 1;
				END TRY
				BEGIN CATCH
					SET @deleted = 0;
				END CATCH;
		END;
END;

