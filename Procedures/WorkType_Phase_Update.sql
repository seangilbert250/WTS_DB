USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkType_Phase_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkType_Phase_Update]

GO

CREATE PROCEDURE [dbo].[WorkType_Phase_Update]
	@WorkTypePhaseID int,
	@PhaseID int,
	@WorkTypeID int,
	@Description nvarchar(255) = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;

	
	IF ISNULL(@WorkTypePhaseID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WorkType_PHASE WHERE WorkType_PHASEID = @WorkTypePhaseID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					UPDATE WorkType_PHASE
					SET
						WorkTypeID = @WorkTypeID
						, PDDTDR_PHASEID = @PhaseID
						, [DESCRIPTION] = @Description
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkType_PHASEID = @WorkTypePhaseID;

					SET @saved = 1; 
				END;
		END;
END;

GO
