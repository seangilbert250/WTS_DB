USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Get]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AOREstimation_Get]
	@AORReleaseID INT = 0,
	@IncludeArchive INT = 0
AS
BEGIN
	SELECT '' as X
	     , AOREstimationID
	     , AOREstimationName
		 , Description
		 , Notes
		 --, isnull(Archive,0) as Archive
		 , CONCAT(CreatedBy, ': ',  LEFT(CONVERT(varchar, CreatedDate, 120),10)) as CreatedBy
		 , CONCAT(UpdatedBy, ': ',  LEFT(CONVERT(varchar, UpdatedDate, 120),10)) as UpdatedBy
		 , '' as Y
	FROM AOREstimation
	WHERE isnull(Archive,0) = 0
	;
END;

GO
