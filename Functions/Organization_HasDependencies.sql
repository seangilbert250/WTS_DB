USE WTS
GO

IF OBJECT_ID (N'dbo.Organization_HasDependencies', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[Organization_HasDependencies];
GO


CREATE FUNCTION [dbo].[Organization_HasDependencies]
(
	@OrganizationID int
)
RETURNS bit
AS
BEGIN
	DECLARE @count int;
	SET @count = 0;

	
	SELECT @count = COUNT(WORKREQUESTID)
	FROM 
		WORKREQUEST WR
	WHERE
		WR.ORGANIZATIONID = @OrganizationID;
		
	IF ISNULL(@count,0) > 0
	BEGIN
		RETURN 1;
	END;

	SELECT @count = COUNT(WTS_RESOURCEID)
	FROM 
		WTS_RESOURCE wr
	WHERE
		wr.ORGANIZATIONID = @OrganizationID;
		
	IF ISNULL(@count,0) > 0
	BEGIN
		RETURN 1;
	END;

	RETURN 0;
END;

GO
