use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[RQMTDescriptionType_Update]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[RQMTDescriptionType_Update]
go

set ansi_nulls on
go
set quoted_identifier on
go

CREATE PROCEDURE [dbo].[RQMTDescriptionType_Update]
	@RQMTDescriptionTypeID int,
	@RQMTDescriptionType nvarchar(150),
	@Description nvarchar(500) = null,
	@Sort int = null,
	@Archive bit = 0,
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

	IF ISNULL(@RQMTDescriptionTypeID,0) > 0
		BEGIN
			SELECT @count = COUNT(*) FROM RQMTDescriptionType WHERE RQMTDescriptionTypeID = @RQMTDescriptionTypeID;

			IF (ISNULL(@count,0) > 0)
				BEGIN
					SELECT @count = COUNT(*) FROM RQMTDescriptionType
					WHERE RQMTDescriptionType = @RQMTDescriptionType
						AND RQMTDescriptionTypeID != @RQMTDescriptionTypeID;

					IF (ISNULL(@count,0) > 0)
						BEGIN
							SET @duplicate = 1;
							SET @saved = 0;
							RETURN;
						END;

					--UPDATE NOW
					UPDATE RQMTDescriptionType
					SET
						RQMTDescriptionType = @RQMTDescriptionType
						, [Description] = @Description
						, SORT = @Sort
						, ARCHIVE = @Archive
						, UPDATEDBY = @UpdatedBy
						, UPDATEDDATE = @date
					WHERE
						RQMTDescriptionTypeID = @RQMTDescriptionTypeID;
					
					SET @saved = 1; 
				END;
		END;
END;

GO
