USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkloadGroup_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkloadGroup_Add]

GO

CREATE PROCEDURE [dbo].[WorkloadGroup_Add]
	@WorkloadGroup nvarchar(50),
	@Description nvarchar(500) = null,
	@ProposedPriorityRank int = null,
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

	SELECT @exists = COUNT(WorkloadGroupID) FROM [WorkloadGroup] WHERE [WorkloadGroup] = @WorkloadGroup;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO [WorkloadGroup](
		WorkloadGroup
		, [Description]
		, ProposedPriorityRank
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@WorkloadGroup
		, @Description
		, @ProposedPriorityRank
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END

GO
