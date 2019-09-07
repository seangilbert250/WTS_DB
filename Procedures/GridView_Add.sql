ALTER PROCEDURE [dbo].[GridView_Add]
	@GridNameID int,
	@ViewName nvarchar(50),
	@SessionID nvarchar(100) = null,
	@WTS_ResourceID int = null,
	@DefaultSelection bit = 1,
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
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @exists int = 0;
	SET @newID = 0;

	IF @SessionID IS NULL AND @WTS_ResourceID IS NOT NULL
		BEGIN
			SELECT @exists = COUNT(*) FROM GridView 
			WHERE 
				GridNameID = @GridNameID
				AND UPPER(ViewName) = UPPER(@ViewName)
				AND WTS_RESOURCEID = @WTS_ResourceID;

			IF ISNULL(@exists,0) > 0
				RETURN;
		END;

	SELECT @exists = COUNT(*) FROM GridView 
	WHERE 
		GridNameID = @GridNameID
		AND ViewName = @ViewName
		AND WTS_RESOURCEID = @WTS_ResourceID
		AND SessionID = @SessionID;

	IF ISNULL(@WTS_ResourceID, 0) > 0 AND ISNULL(@SessionID,'') != '' AND ISNULL(@exists,0) > 0
		BEGIN
			DELETE FROM GridView
			WHERE
				GridNameID = @GridNameID
				AND ViewName = @ViewName
				AND WTS_RESOURCEID = @WTS_ResourceID
				AND SessionID = @SessionID;
		END;
		
	INSERT INTO GridView(
		GridNameID
		, WTS_RESOURCEID
		, SessionID
		, ViewName
		, Tier1Columns
		, Tier1ColumnOrder
		, Tier1SortOrder
		, Tier1RollupGroup
		, Tier2Columns
		, Tier2ColumnOrder
		, Tier2SortOrder
		, Tier2RollupGroup
		, Tier3Columns
		, Tier3ColumnOrder
		, Tier3SortOrder
		, DefaultSelection
		, SORT_ORDER
		, SectionsXML
		, ViewType
		, Archive
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@GridNameID
		, @WTS_ResourceID
		, @SessionID
		, @ViewName
		, @Tier1Columns
		, @Tier1ColumnOrder
		, @Tier1SortOrder
		, @Tier1RollupGroup
		, @Tier2Columns
		, @Tier2ColumnOrder
		, @Tier2SortOrder
		, @Tier2RollupGroup
		, @Tier3Columns
		, @Tier3ColumnOrder
		, @Tier3SortOrder
		, 0
		, @Sort_Order
		, @SectionsXML
		, @ViewType
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;