USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ContractCRReportInfo_Update]    Script Date: 3/15/2018 11:52:26 AM ******/
DROP PROCEDURE [dbo].[ContractCRReportInfo_Update]
GO

/****** Object:  StoredProcedure [dbo].[ContractCRReportInfo_Update]    Script Date: 3/15/2018 11:52:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ContractCRReportInfo_Update]
	@ContractIDs NVARCHAR(50),
	@UserID int = 0,
	@saved bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @sql NVARCHAR(MAX) = '';
	DECLARE @UpdatedBy NVARCHAR(255) = 'WTS_ADMIN';
	DECLARE @date NVARCHAR(30);

	SET @date = CONVERT(NVARCHAR(30), getdate());

	SELECT @UpdatedBy = replace(USERNAME, '''', '''''')
	FROM WTS_RESOURCE
	WHERE WTS_RESOURCEID = @UserID;

	SET @saved = 0;
	if (@ContractIDs != '')
		set @sql = '
		UPDATE [CONTRACT]
		SET CRREPORTLASTRUNBY = ''' + @UpdatedBy + ''', 
			CRREPORTLASTRUNDATE = ''' + @date + '''
		 WHERE ISNULL(CONTRACTID, 0) in (' + @ContractIDs + ') ';
	begin
		execute sp_executesql @sql;
	end;
		
	SET @saved = 1; 
END;

GO


