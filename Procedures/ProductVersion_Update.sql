USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ProductVersion_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [ProductVersion_Update]

GO

CREATE PROCEDURE [dbo].[ProductVersion_Update]
	@ProductVersionID int,
	@ProductVersion nvarchar(50),
	@Description nvarchar(500) = null,
	@Narrative nvarchar(max) = null,
	@StartDate nvarchar(20) = null,
	@EndDate nvarchar(20) = null,
	@DefaultSelection bit = 0,
	@Sort_Order int = null,
	@StatusID int = null,
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

	IF ISNULL(@ProductVersionID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM ProductVersion WHERE ProductVersionID = @ProductVersionID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE ProductVersion
					SET
						ProductVersion = @ProductVersion
						, [DESCRIPTION] = @Description
						, Narrative = @Narrative
						, StartDate = @StartDate
						, EndDate = @EndDate
						, DefaultSelection = @DefaultSelection
						, SORT_ORDER = @Sort_Order
						, StatusID = @StatusID
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						ProductVersionID = @ProductVersionID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
