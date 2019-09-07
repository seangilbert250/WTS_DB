USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Allocation_System_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Allocation_System_Update]

GO

CREATE PROCEDURE [dbo].[Allocation_System_Update]
	@Allocation_SystemID int,
	@ALLOCATIONID int,
	@WTS_SYSTEMID int = null,
	@Description nvarchar(MAX) = null,
	@ProposedPriority int,
	@ApprovedPriority int,
	@Archive bit = 0,
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

	IF ISNULL(@Allocation_SystemID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM Allocation_System WHERE Allocation_SystemID = @Allocation_SystemID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--Check for duplicate
					SELECT @count = COUNT(*) FROM Allocation_System 
					WHERE ALLOCATIONID = @ALLOCATIONID
						AND WTS_SYSTEMID = @WTS_SYSTEMID
						AND Allocation_SystemID != @Allocation_SystemID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE Allocation_System
					SET
						ALLOCATIONID = @ALLOCATIONID
						, WTS_SYSTEMID = @WTS_SYSTEMID
						, [DESCRIPTION] = @Description
						, ProposedPriority = @ProposedPriority
						, ApprovedPriority = @ApprovedPriority
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						Allocation_SystemID = @Allocation_SystemID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
