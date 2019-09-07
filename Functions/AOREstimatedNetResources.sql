USE WTS
GO

IF OBJECT_ID (N'dbo.AOREstimatedNetResources', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[AOREstimatedNetResources];
GO


CREATE FUNCTION [dbo].[AOREstimatedNetResources]
(
	@AORReleaseID int
)
RETURNS decimal(10,2)
AS
BEGIN
	DECLARE @estimatedResources decimal(10,2);
	SET @estimatedResources = 0;

	SELECT @estimatedResources = isnull(EstimatedResources,0)
		FROM AORRelease
		WHERE AORReleaseID = @AORReleaseID;

	RETURN @estimatedResources;
END;

GO