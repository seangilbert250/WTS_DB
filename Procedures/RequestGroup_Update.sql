USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[RequestGroup_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [RequestGroup_Update]

GO

CREATE PROCEDURE [dbo].[RequestGroup_Update]
	@RequestGroupID int,
	@RequestGroup nvarchar(50),
	@Description nvarchar(max) = null,
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

	IF ISNULL(@RequestGroupID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM RequestGroup WHERE RequestGroupID = @RequestGroupID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE RequestGroup
					SET
						RequestGroup = @RequestGroup
						, [DESCRIPTION] = @Description
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						RequestGroupID = @RequestGroupID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
