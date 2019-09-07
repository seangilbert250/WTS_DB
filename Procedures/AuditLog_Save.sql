USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AuditLog_Save]    Script Date: 8/16/2018 2:45:05 PM ******/
DROP PROCEDURE [dbo].[AuditLog_Save]
GO

/****** Object:  StoredProcedure [dbo].[AuditLog_Save]    Script Date: 8/16/2018 2:45:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AuditLog_Save]
(
	@ItemID INT,
	@ParentItemID INT = NULL,
	@AuditLogTypeID INT,
	@ITEM_UPDATETYPEID INT,
	@FieldChanged NVARCHAR(100),
	@OldValue NVARCHAR(MAX) = NULL,
	@NewValue NVARCHAR(MAX) = NULL,
	@UpdatedDate DATETIME = NULL,
	@UpdatedBy NVARCHAR(MAX)
)
AS
BEGIN
	IF @UpdatedDate IS NULL SET @UpdatedDate = GETDATE()

	-- if we are setting one of the text values below, we can pass in ID's for values instead of the names and this block will
	-- set the values to the correct names (this allows for cleaner code from other stored procedures)
	IF @FieldChanged in (
							'WTS_SYSTEMSUITE', 'WTS_SYSTEM', 'WorkArea', 'WorkloadGroup',
							'RQMT', 'RQMTType', 'RQMTComplexity', 'RQMTDefectImpact', 'RQMTStage', 'RQMTStatus', 'RQMTCriticality',
							'WTS_RESOURCE', 'Assigned To', 'Primary Resource'
						)
	BEGIN
		DECLARE @idx INT = 0
		WHILE @idx < 2
		BEGIN
			DECLARE @IsNumeric INT = (CASE WHEN @idx = 0 THEN ISNUMERIC(@OldValue) ELSE ISNUMERIC(@NewValue) END)
			DECLARE @value NVARCHAR(MAX) = (CASE WHEN @idx = 0 THEN @OldValue ELSE @NewValue END)

			IF @IsNumeric = 1
			BEGIN
				SET @value =
				(CASE 
					WHEN @FieldChanged = 'WTS_SYSTEMSUITE' THEN (SELECT WTS_SYSTEM_SUITE FROM WTS_SYSTEM_SUITE WHERE WTS_SYSTEM_SUITEID = @value)
					WHEN @FieldChanged = 'WTS_SYSTEM' THEN (SELECT WTS_SYSTEM FROM WTS_SYSTEM WHERE WTS_SYSTEMID = @value)
					WHEN @FieldChanged = 'WorkArea' THEN (SELECT WorkArea FROM WorkArea WHERE WorkAreaID = @value)
					WHEN @FieldChanged = 'WorkloadGroup' THEN (SELECT WorkloadGroup FROM WorkloadGroup WHERE WorkloadGroupID = @value)

					WHEN @FieldChanged = 'RQMT' THEN (SELECT RQMT FROM RQMT WHERE RQMTID = @value)
					WHEN @FieldChanged = 'RQMTType' THEN (SELECT RQMTType FROM RQMTType WHERE RQMTTypeID = @value)
					WHEN @FieldChanged = 'RQMTComplexity' THEN (SELECT RQMTComplexity FROM RQMTComplexity WHERE RQMTComplexityID = @value)
					WHEN @FieldChanged = 'RQMTDefectImpact' THEN (SELECT RQMTAttribute FROM RQMTAttribute WHERE RQMTAttributeID = @value)
					WHEN @FieldChanged = 'RQMTStage' THEN (SELECT RQMTAttribute FROM RQMTAttribute WHERE RQMTAttributeID = @value)
					WHEN @FieldChanged = 'RQMTStatus' THEN (SELECT RQMTAttribute FROM RQMTAttribute WHERE RQMTAttributeID = @value)
					WHEN @FieldChanged = 'RQMTCriticality' THEN (SELECT RQMTAttribute FROM RQMTAttribute WHERE RQMTAttributeID = @value)

					WHEN @FieldChanged = 'WTS_RESOURCE' THEN (SELECT USERNAME FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @value)
					WHEN @FieldChanged = 'Assigned To' THEN (SELECT FIRST_NAME + ' ' + LAST_NAME FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @value)
					WHEN @FieldChanged = 'Primary Resource' THEN (SELECT FIRST_NAME + ' ' + LAST_NAME FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @value)

					
				END)

				IF @idx = 0 SET @OldValue = @value ELSE SET @NewValue = @value
			END
			
			SET @idx = @idx + 1
		END
	END

	IF (
		(@OldValue IS NULL AND @NewValue IS NOT NULL) OR
		(@NewValue IS NULL AND @OldValue IS NOT NULL) OR
		(@OldValue <> @NewValue)
	)	
	BEGIN
		INSERT INTO dbo.AuditLog VALUES
		(
			@ItemID,
			@ParentItemID,
			@AuditLogTypeID,
			@ITEM_UPDATETYPEID,
			@FieldChanged,
			@OldValue,
			@NewValue,
			@UpdatedDate,
			@UpdatedBy
		)
	END
END
GO


