USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_ResourceDevelopers_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WTS_ResourceDevelopers_Get]

GO

CREATE PROCEDURE [dbo].[WTS_ResourceDevelopers_Get] 

	@IsDeveloper int = 0,
	@IsBusAnalyst int = 0,
	@IsAMCGEO int = 0,
	@IsCASUser int = 0,
	@IsALODUser int = 0

AS
BEGIN

	SELECT WTS_ResourceID FROM WTS_Resource 
	WHERE IsDeveloper = @IsDeveloper 
	OR IsBusAnalyst = @IsBusAnalyst
	OR IsAMCGEO = @IsAMCGEO
	OR IsCASUser = @IsCASUser
	OR IsALODUser = @IsALODUser;

END;

GO
