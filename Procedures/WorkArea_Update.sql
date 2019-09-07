USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkArea_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkArea_Update]

GO

CREATE PROCEDURE [dbo].[WorkArea_Update]
	@WorkAreaID int,
	@WorkArea nvarchar(50),
	@Description nvarchar(500) = null,
	@ProposedPriorityRank int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;

	IF ISNULL(@WorkAreaID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WorkArea WHERE WorkAreaID = @WorkAreaID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WorkArea
					SET
						WorkArea = @WorkArea
						, [DESCRIPTION] = @Description
						, ProposedPriorityRank = @ProposedPriorityRank
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WorkAreaID = @WorkAreaID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
