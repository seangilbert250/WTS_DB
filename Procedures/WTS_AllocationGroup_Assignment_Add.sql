USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_AllocationGroup_Assignment_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_AllocationGroup_Assignment_Add
GO

CREATE PROCEDURE [dbo].[WTS_AllocationGroup_Assignment_Add]
	@ALLOCATIONID nvarchar(50), --Child ID
	@DESCRIPTION nvarchar(50) = null,
	@SORT_ORDER int,
	@ARCHIVE int,
	@UPDATEDBY nvarchar(255) = 'WTS_ADMIN',
	@DefaultSMEID int,
	@DefaultBusinessResourceID int,
	@DefaultTechnicalResourceID int,
	@DefaultAssignedToID int,
	@ALLOCATIONGROUPID int,	--Parent ID
	@exists bit output,
	@newID int output

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;

	BEGIN;
		UPDATE [WTS].[dbo].ALLOCATION
			SET ALLOCATIONGROUPID = @ALLOCATIONGROUPID
				,[DESCRIPTION] = @DESCRIPTION
				,SORT_ORDER = @SORT_ORDER
				,DefaultSMEID = @DefaultSMEID
				,DefaultBusinessResourceID = @DefaultBusinessResourceID
				,DefaultTechnicalResourceID = @DefaultTechnicalResourceID
				,DefaultAssignedToID = @DefaultAssignedToID
				,ARCHIVE = @ARCHIVE
				,UPDATEDBY = @UPDATEDBY
				,UPDATEDDATE = @date
			WHERE ALLOCATIONID = @ALLOCATIONID
	
	
		SELECT @newID = SCOPE_IDENTITY(); 
	END;
END;

