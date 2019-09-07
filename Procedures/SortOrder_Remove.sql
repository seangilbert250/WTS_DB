USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SortOrder_Remove]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SortOrder_Remove]
GO


CREATE PROCEDURE [dbo].[SortOrder_Remove]

	@SessionID nvarchar(255),
	@UserName nvarchar(255),
	@GridNameID int,
	@GridName nvarchar(255)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE
	FROM 
		sortValues 
	WHERE UserName = @UserName AND GridName = @GridName;
END
