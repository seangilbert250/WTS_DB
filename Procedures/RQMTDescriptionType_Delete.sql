use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[RQMTDescriptionType_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[RQMTDescriptionType_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

CREATE PROCEDURE [dbo].[RQMTDescriptionType_Delete]
	@RQMTDescriptionTypeID int, 
	@exists int output,
	@hasDependencies int output,
	@deleted int output,
	@archived int output
AS
BEGIN
	SET @exists = 0;
	SET @hasDependencies = 0;
	SET @deleted = 0;
	SET @archived = 0;

	SELECT @exists = COUNT(RQMTDescriptionTypeID)
	FROM RQMTDescriptionType
	WHERE 
		RQMTDescriptionTypeID = @RQMTDescriptionTypeID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	SELECT @hasDependencies = COUNT(*) FROM RQMTDescription WHERE RQMTDescriptionTypeID = @RQMTDescriptionTypeID;
	--SELECT @hasDependencies = COUNT(*) FROM WORKITEM_TASK WHERE EffortAreaID = @EffortAreaID;
	--SELECT @hasDependencies = COUNT(*) FROM EffortArea_Size WHERE EffortAreaID = @EffortAreaID;

	IF ISNULL(@hasDependencies,0) > 0
		BEGIN
			--archive the user instead
			UPDATE RQMTDescriptionType
			SET ARCHIVE = 1
			WHERE
				RQMTDescriptionTypeID = @RQMTDescriptionTypeID;

			SET @archived = 1;
			RETURN;
		END;
	ELSE
		BEGIN
			DELETE FROM RQMTDescriptionType
			WHERE RQMTDescriptionTypeID = @RQMTDescriptionTypeID;

			SET @deleted = 1;
		END;

END;

GO
