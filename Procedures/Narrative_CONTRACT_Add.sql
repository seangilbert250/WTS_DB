USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_CONTRACT_Add]    Script Date: 5/1/2018 9:59:42 AM ******/
DROP PROCEDURE [dbo].[Narrative_CONTRACT_Add]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_CONTRACT_Add]    Script Date: 5/1/2018 9:59:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[Narrative_CONTRACT_Add]
	@NarrativeID int,
	@ProductVersionID int = null,
	@CONTRACTID int = null,
	@WorkloadAllocationID int = null,
	@ImageID int = null,
	@Sort int = null,
	@CreatedBy nvarchar(255) = 'WTS',
	@duplicateSort bit output,
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @duplicateSort = 0;
	SET @exists = 0;
	SET @newID = 0;

	SELECT @exists = COUNT(*) FROM Narrative_CONTRACT 
	WHERE NarrativeID = @NarrativeID 
	and CONTRACTID = @CONTRACTID
	and ProductVersionID = @ProductVersionID
	;

	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	SELECT @duplicateSort = COUNT(*) FROM Narrative_CONTRACT 
	WHERE CONTRACTID = @CONTRACTID
	and ProductVersionID = @ProductVersionID
	and Sort = @Sort
	;

	IF (ISNULL(@duplicateSort,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO Narrative_CONTRACT(
		NarrativeID
		, ProductVersionID
		, CONTRACTID
		, WorkloadAllocationID
		, ImageID
		, Sort
		, Archive
		, CreatedBy
		, CreatedDate
		, UpdatedBy
		, UpdatedDate
	)
	VALUES(
		@NarrativeID
		, @ProductVersionID
		, @CONTRACTID
		, @WorkloadAllocationID
		, @ImageID
		, @Sort
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();
END;


SELECT 'Executing File [Procedures\Narrative_CONTRACT_Add.sql]';
GO

