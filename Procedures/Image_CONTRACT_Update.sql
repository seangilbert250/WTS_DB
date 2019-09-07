USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Image_CONTRACT_Update]    Script Date: 4/27/2018 7:45:18 AM ******/
DROP PROCEDURE [dbo].[Image_CONTRACT_Update]
GO

/****** Object:  StoredProcedure [dbo].[Image_CONTRACT_Update]    Script Date: 4/27/2018 7:45:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Image_CONTRACT_Update]
	@Image_CONTRACTID int,
	@ImageID int,
	@ProductVersionID int = null,
	@CONTRACTID int = null,
	@WorkloadAllocationID int = null,
	@Sort int = null,
	@Archive bit = 0,
	@UpdatedBy nvarchar(255) = 'WTS',
	@duplicate bit output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @date datetime = GETDATE();
	DECLARE @count int;
	SET @count = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@Image_CONTRACTID,0) > 0
		BEGIN
				SELECT @count = COUNT(*) FROM Image_CONTRACT WHERE Image_CONTRACTID = @Image_CONTRACTID;

				IF (ISNULL(@count,0) > 0)
					BEGIN
						--Check for duplicate
						SELECT @count = COUNT(*) FROM Image_CONTRACT 
						WHERE ImageID = @ImageID
							AND CONTRACTID = @CONTRACTID
							and ProductVersionID = @ProductVersionID
							AND Image_CONTRACTID != @Image_CONTRACTID;

						IF (ISNULL(@count,0) > 0)
							BEGIN
								SET @duplicate = 1;
								RETURN;
							END;

						--UPDATE NOW
						UPDATE Image_CONTRACT
						SET
							ImageID = @ImageID
							, ProductVersionID = @ProductVersionID
							, CONTRACTID = @CONTRACTID
							, WorkloadAllocationID = @WorkloadAllocationID
							, Sort = @Sort
							, Archive = @Archive
							, UpdatedBy = @UpdatedBy
							, UpdatedDate = @date
						WHERE
							Image_CONTRACTID = @Image_CONTRACTID;
					
						SET @saved = 1; 
					END;	
		END;
END;


SELECT 'Executing File [Procedures\Image_CONTRACT_Add.sql]';
GO

