USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[PDDTDR_Phase_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [PDDTDR_Phase_Update]

GO

CREATE PROCEDURE [dbo].[PDDTDR_Phase_Update]
	@PDDTDR_PhaseID int,
	@PDDTDR_Phase nvarchar(50),
	@Description nvarchar(500) = null,
	@Sort_Order int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @saved = 0;

	IF ISNULL(@PDDTDR_PhaseID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM PDDTDR_Phase WHERE PDDTDR_PhaseID = @PDDTDR_PhaseID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE PDDTDR_Phase
					SET
						PDDTDR_Phase = @PDDTDR_Phase
						, [DESCRIPTION] = @Description
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						PDDTDR_PhaseID = @PDDTDR_PhaseID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
