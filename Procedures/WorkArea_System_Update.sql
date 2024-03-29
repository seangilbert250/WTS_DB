USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkArea_System_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WorkArea_System_Update
GO

CREATE PROCEDURE [dbo].[WorkArea_System_Update]
	@WorkArea_SystemID int,
	@WorkAreaID int,
	@WTS_SYSTEMID int = null,
	@Description nvarchar(MAX) = null,
	@ProposedPriority int,
	@ApprovedPriority int,
	@Archive bit = 0,
	@CV nvarchar(1),
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

	IF ISNULL(@WorkArea_SystemID,0) > 0
		BEGIN
			IF @CV = 0
				SELECT @count = COUNT(*) FROM WorkArea_System WHERE WorkArea_SystemID = @WorkArea_SystemID;

				IF (ISNULL(@count,0) > 0)
					BEGIN
						--Check for duplicate
						SELECT @count = COUNT(*) FROM WorkArea_System 
						WHERE WorkAreaID = @WorkAreaID
							AND WTS_SYSTEMID = @WTS_SYSTEMID
							AND WorkArea_SystemID != @WorkArea_SystemID;

						IF (ISNULL(@count,0) > 0)
							BEGIN
								SET @duplicate = 1;
								RETURN;
							END;

						--UPDATE NOW
						UPDATE WorkArea_System
						SET
							WorkAreaID = @WorkAreaID
							, WTS_SYSTEMID = @WTS_SYSTEMID
							, [DESCRIPTION] = @Description
							, ProposedPriority = @ProposedPriority
							, ApprovedPriority = @ApprovedPriority
							, ARCHIVE = @Archive
							, UPDATEDBY = @UpdatedBy
							, UPDATEDDATE = @date
						WHERE
							WorkArea_SystemID = @WorkArea_SystemID;
					
						SET @saved = 1; 
					END;	
			ELSE
				SELECT @count = COUNT(*) FROM Allocation_System WHERE Allocation_SystemId = @WorkArea_SystemID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--Check for duplicate
					SELECT @count = COUNT(*) FROM Allocation_System 
					WHERE ALLOCATIONID = @WorkAreaID
						AND WTS_SYSTEMID = @WTS_SYSTEMID
						AND Allocation_SystemId != @WorkArea_SystemID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE Allocation_System
					SET
						ALLOCATIONID = @WorkAreaID
						, WTS_SYSTEMID = @WTS_SYSTEMID
						, [DESCRIPTION] = @Description
						, ProposedPriority = @ProposedPriority
						, ApprovedPriority = @ApprovedPriority
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						Allocation_SystemId = @WorkArea_SystemID;
					
					SET @saved = 1; 
				END;		
		END;
END;

