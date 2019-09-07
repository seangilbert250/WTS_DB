USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SortOrder_Apply]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SortOrder_Apply]
GO

CREATE PROCEDURE [dbo].[SortOrder_Apply]

	@SessionID nvarchar(255),
	@UserName nvarchar(255),
	@GridNameID int,
	@GridName nvarchar(255),
	@sortValues nvarchar(500) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @exists int;
	SET @exists = 0

	SELECT @exists = COUNT(*) FROM sortValues WHERE UserName = @UserName AND GridName = @GridName;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			UPDATE [sortValues] 
			SET sortValues = @sortValues 
			WHERE UserName = @UserName 
			AND GridName = @GridName;
		END
	ELSE
		BEGIN
			INSERT INTO [sortValues](
			 SessionID 
			 , UserName 
			 , GridNameID 
			 , GridName
			 , sortValues) 
			VALUES( 
			@SessionID  
			, @UserName 
			, @GridNameID
			, @GridName
			, @sortValues)
		END

END;

