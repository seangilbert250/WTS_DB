USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SortOrder_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SortOrder_Delete]
GO

CREATE PROCEDURE [dbo].[SortOrder_Delete]

	@SessionID nvarchar(255),
	@UserName nvarchar(255),
	@GridName nvarchar(255)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM sortValues WHERE UserName = @UserName AND GridName = @GridName;

END
