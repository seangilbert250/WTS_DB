USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkArea_System_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WorkArea_System_Add
GO

CREATE PROCEDURE [dbo].[WorkArea_System_Add]
	@WorkAreaID int,
	@WTS_SYSTEMID int = null,
	@Description nvarchar(500) = null,
	@ProposedPriority int,
	@ApprovedPriority int,
	@CV nvarchar(1),
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;
	

	IF @CV = 0
		BEGIN
			SELECT @exists = COUNT(*) FROM WorkArea_System WHERE WorkAreaID = @WorkAreaID AND WTS_SYSTEMID = @WTS_SYSTEMID;
			IF (ISNULL(@exists,0) > 0)
				BEGIN
					RETURN;
				END;
			INSERT INTO WorkArea_System(
				WorkAreaID
				, WTS_SYSTEMID
				, [DESCRIPTION]
				, ProposedPriority
				, ApprovedPriority
				, ARCHIVE
				, CREATEDBY
				, CREATEDDATE
				, UPDATEDBY
				, UPDATEDDATE
			)
			VALUES(
				@WorkAreaID
				, @WTS_SYSTEMID
				, @Description
				, @ProposedPriority
				, @ApprovedPriority
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			);
			SELECT @newID = SCOPE_IDENTITY();
		END;
	ELSE
		BEGIN
			SELECT @exists = COUNT(*) FROM Allocation_System WHERE ALLOCATIONID = @WorkAreaID AND WTS_SYSTEMID = @WTS_SYSTEMID;
			IF (ISNULL(@exists,0) > 0)
				BEGIN
					RETURN;
				END;

			INSERT INTO Allocation_System(
				ALLOCATIONID
				, WTS_SYSTEMID
				, [DESCRIPTION]
				, ProposedPriority
				, ApprovedPriority
				, ARCHIVE
				, CREATEDBY
				, CREATEDDATE
				, UPDATEDBY
				, UPDATEDDATE
			)
			VALUES(
				@WorkAreaID
				, @WTS_SYSTEMID
				, @Description
				, @ProposedPriority
				, @ApprovedPriority
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			);
			SELECT @newID = SCOPE_IDENTITY();
		END;
END;

