ALTER PROCEDURE [dbo].[GridView_Update]
	@GridViewID int,
	@GridNameID int,
	@ViewName nvarchar(50),
	@SessionID nvarchar(100) = null,
	@WTS_ResourceID int = null,
	@Tier1Columns nvarchar(max) = null,
	@Tier1ColumnOrder nvarchar(max) = null,
	@Tier1SortOrder nvarchar(1000) = null,
	@Tier1RollupGroup nvarchar(50) = null,
	@Tier2Columns nvarchar(1000) = null,
	@Tier2ColumnOrder nvarchar(max) = null,
	@Tier2SortOrder nvarchar(1000) = null,
	@Tier2RollupGroup nvarchar(50) = null,
	@Tier3Columns nvarchar(1000) = null,
	@Tier3ColumnOrder nvarchar(max) = null,
	@Tier3SortOrder nvarchar(1000) = null,
	@Sort_Order int = null,
	@SectionsXML xml = null,
	@ViewType int = null,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@GridViewID,0) = 0
		RETURN;

	SELECT @count = COUNT(*) FROM GridView WHERE GridViewID = @GridViewID;

	IF ISNULL(@count,0) = 0
		RETURN;

	--Check for duplicate
	SELECT @count = COUNT(*) FROM GridView 
	WHERE GridNameID = @GridNameID
		AND ViewName = @ViewName
		AND WTS_RESOURCEID = @WTS_ResourceID
		AND SessionID = @SessionID
		AND GridViewID != @GridViewID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			SET @duplicate = 1;
			RETURN;
		END;

	--UPDATE NOW
	UPDATE GridView
	SET
		GridNameID = @GridNameID
		, WTS_RESOURCEID = @WTS_ResourceID
		, SessionID = @SessionID
		, ViewName = @ViewName
		, Tier1Columns = @Tier1Columns
		, Tier1ColumnOrder = @Tier1ColumnOrder
		, Tier1SortOrder = @Tier1SortOrder
		, Tier1RollupGroup = @Tier1RollupGroup
		, Tier2Columns = @Tier2Columns
		, Tier2ColumnOrder = @Tier2ColumnOrder
		, Tier2SortOrder = @Tier2SortOrder
		, Tier2RollupGroup = @Tier2RollupGroup
		, Tier3Columns = @Tier3Columns
		, Tier3ColumnOrder = @Tier3ColumnOrder
		, Tier3SortOrder = @Tier3SortOrder
		, SORT_ORDER = @Sort_Order
		, SectionsXML = @SectionsXML
		, ViewType = @ViewType
		, UPDATEDBY = @UpdatedBy
		, UPDATEDDATE = @date
	WHERE
		GridViewID = @GridViewID;

	SET @saved = 1;

END;