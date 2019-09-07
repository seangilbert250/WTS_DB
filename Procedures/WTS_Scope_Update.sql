USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_Scope_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_Scope_Update]

GO

CREATE PROCEDURE [dbo].[WTS_Scope_Update]
	@WTS_ScopeID int,
	@Scope nvarchar(50),
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
	DECLARE @count int = 0;
	SET @saved = 0;

	IF ISNULL(@WTS_ScopeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM WTS_Scope WHERE WTS_ScopeID = @WTS_ScopeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE WTS_Scope
					SET
						Scope = @Scope
						, [DESCRIPTION] = @Description
						, SORT_ORDER = @Sort_Order
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						WTS_ScopeID = @WTS_ScopeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
