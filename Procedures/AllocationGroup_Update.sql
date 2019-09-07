USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AllocationGroup_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE AllocationGroup_Update

GO

CREATE PROCEDURE [dbo].AllocationGroup_Update
	@ALLOCATIONGROUPID int,
	@ALLOCATIONGROUP nvarchar(50),
	@DESCRIPTION nvarchar(50) = null,
	@NOTES nvarchar(50) = null,
	@PRIORTY int,
	@DAILYMEETINGS bit = 0,
	@ARCHIVE bit = 0,
	@UPDATEDBY nvarchar(255) = 'WTS_ADMIN',
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

	IF ISNULL(@ALLOCATIONGROUPID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM [WTS].[dbo].[AllocationGroup] WHERE ALLOCATIONGROUPID = @ALLOCATIONGROUPID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					--UPDATE NOW
					UPDATE AllocationGroup
					SET
						 ALLOCATIONGROUP = @ALLOCATIONGROUP
						, [DESCRIPTION] = @DESCRIPTION
						, NOTES = @NOTES
						, PRIORTY = @PRIORTY
						, DAILYMEETINGS = @DAILYMEETINGS
						, ARCHIVE = @ARCHIVE
						, UPDATEDBY = @UPDATEDBY
						, UPDATEDDATE = @date
					WHERE
						ALLOCATIONGROUPID = @ALLOCATIONGROUPID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO