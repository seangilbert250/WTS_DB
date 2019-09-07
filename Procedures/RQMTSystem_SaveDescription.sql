USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystem_SaveDescription]    Script Date: 9/10/2018 4:51:31 PM ******/
DROP PROCEDURE [dbo].[RQMTSystem_SaveDescription]
GO

/****** Object:  StoredProcedure [dbo].[RQMTSystem_SaveDescription]    Script Date: 9/10/2018 4:51:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[RQMTSystem_SaveDescription]
(
	@RQMTSystemID INT,
	@RQMTSet_RQMTSystemID INT,
	@RQMTSystemRQMTDescriptionID INT,
	@RQMTDescriptionID INT OUTPUT,
	@RQMTDescription NVARCHAR(MAX),
	@RQMTDescriptionTypeID INT,
	@Edit BIT,
	@ChangeMode NVARCHAR(10),
	@CreatedBy NVARCHAR(50),
	@UpdatedBy NVARCHAR(50)
)
AS
BEGIN

	-- if @Edit is true, we will edit the existing rdesc being used by the rsys if a desc exists in the rsys, otherwise we will create a new one if there is no matching rdesc

	DECLARE @now DATETIME = GETDATE()
	DECLARE @RQMTSetID INT	 
	DECLARE @count INT
	DECLARE @ExistingRQMTDescriptionID INT
	DECLARE @RQMTDescription_OLD NVARCHAR(MAX)
	DECLARE @WTS_SYSTEMID INT

	IF @RQMTSystemID <= 0 SELECT @RQMTSystemID = RQMTSystemID, @RQMTSetID = RQMTSetID FROM RQMTSet_RQMTSystem WHERE RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID

	SELECT @WTS_SYSTEMID = WTS_SYSTEMID FROM RQMTSystem WHERE RQMTSystemID = @RQMTSystemID
	SELECT @ExistingRQMTDescriptionID = RQMTDescriptionID FROM RQMTDescription WHERE RQMTDescription = @RQMTDescription AND RQMTDescriptionTypeID = @RQMTDescriptionTypeID

	IF @RQMTSystemRQMTDescriptionID = -1 -- we are adding a NEW description to a rqmtsystem (create a new entry if it is entirely new, or point rs to an existing desc if it is one that already exists)
	BEGIN
		IF @ExistingRQMTDescriptionID IS NOT NULL -- our new entry points to an exact match of another description, so we will point this entry to that
		BEGIN
			INSERT INTO RQMTSystemRQMTDescription VALUES 
			(@ExistingRQMTDescriptionID, @RQMTSystemID, 0, @CreatedBy, @now, @UpdatedBy, @now)

			SET @RQMTSystemRQMTDescriptionID = SCOPE_IDENTITY()
		END
		ELSE -- we have a new desc/type combination, so create it new
		BEGIN
			INSERT INTO RQMTDescription VALUES
			(@RQMTDescriptionTypeID, @RQMTDescription, 0, 0, @CreatedBy, @now, @UpdatedBy, @now)

			SET @ExistingRQMTDescriptionID = SCOPE_IDENTITY()

			INSERT INTO RQMTSystemRQMTDescription VALUES
			(@ExistingRQMTDescriptionID, @RQMTSystemID, 0, @CreatedBy, @now, @UpdatedBy, @now)	

			SET @RQMTSystemRQMTDescriptionID = SCOPE_IDENTITY()
		END			
		
		EXEC dbo.AuditLog_Save @RQMTSystemRQMTDescriptionID, @RQMTSystemID, 7, 1, 'RQMTDescription', NULL, @RQMTDescription, @now, @UpdatedBy	
	END
	ELSE -- we are EDITING a description in a rqmtsystem (multiple rs may be affected) / also, if the new version points to an existing desc, point THIS RS ONLY to the new desc
	BEGIN
		SELECT
			@RQMTDescription_OLD = rd.RQMTDescription
		FROM RQMTSystemRQMTDescription rsrd JOIN RQMTDescription rd ON (rd.RQMTDescriptionID = rsrd.RQMTDescriptionID)
		WHERE
			rsrd.RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID

		IF @RQMTDescriptionID = 0 SET @RQMTDescriptionID = (SELECT RQMTDescriptionID FROM RQMTSystemRQMTDescription WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID)

		IF @ChangeMode IS NULL OR @ChangeMode = 'all'
		BEGIN
			IF @ExistingRQMTDescriptionID IS NOT NULL
			BEGIN			
				UPDATE RQMTSystemRQMTDescription SET RQMTDescriptionID = @ExistingRQMTDescriptionID WHERE RQMTDescriptionID = @RQMTDescriptionID			
			END
			ELSE
			BEGIN
				SET @ExistingRQMTDescriptionID = (SELECT RQMTDescriptionID FROM RQMTSystemRQMTDescription WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID)
				UPDATE RQMTDescription SET RQMTDescription = @RQMTDescription, RQMTDescriptionTypeID = @RQMTDescriptionTypeID WHERE RQMTDescriptionID = @ExistingRQMTDescriptionID
			END
		END
		ELSE IF @ChangeMode = 'system'
		BEGIN
			IF @ExistingRQMTDescriptionID IS NOT NULL
			BEGIN			
				UPDATE RQMTSystemRQMTDescription SET RQMTDescriptionID = @ExistingRQMTDescriptionID 
				FROM RQMTSystemRQMTDescription rsrd
				JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrd.RQMTSystemID)
				WHERE rsrd.RQMTDescriptionID = @RQMTDescriptionID AND rs.WTS_SYSTEMID = @WTS_SYSTEMID				
			END
			ELSE
			BEGIN
				INSERT INTO RQMTDescription VALUES
				(@RQMTDescriptionTypeID, @RQMTDescription, 0, 0, @CreatedBy, @now, @UpdatedBy, @now)

				SET @ExistingRQMTDescriptionID = SCOPE_IDENTITY()

				UPDATE RQMTSystemRQMTDescription SET RQMTDescriptionID = @ExistingRQMTDescriptionID 
				FROM RQMTSystemRQMTDescription rsrd
				JOIN RQMTSystem rs ON (rs.RQMTSystemID = rsrd.RQMTSystemID)
				WHERE rsrd.RQMTDescriptionID = @RQMTDescriptionID AND rs.WTS_SYSTEMID = @WTS_SYSTEMID	
			END
		END
		ELSE IF @ChangeMode = 'desc'
		BEGIN
			IF @ExistingRQMTDescriptionID IS NOT NULL
			BEGIN			
				UPDATE RQMTSystemRQMTDescription SET RQMTDescriptionID = @ExistingRQMTDescriptionID WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID							
			END
			ELSE
			BEGIN
				INSERT INTO RQMTDescription VALUES
				(@RQMTDescriptionTypeID, @RQMTDescription, 0, 0, @CreatedBy, @now, @UpdatedBy, @now)

				SET @ExistingRQMTDescriptionID = SCOPE_IDENTITY()

				UPDATE RQMTSystemRQMTDescription SET RQMTDescriptionID = @ExistingRQMTDescriptionID WHERE RQMTSystemRQMTDescriptionID = @RQMTSystemRQMTDescriptionID
			END
		END

		EXEC dbo.AuditLog_Save @RQMTSystemRQMTDescriptionID, @RQMTSystemID, 7, 5, 'RQMTDescription', @RQMTDescription_OLD, @RQMTDescription, @now, @UpdatedBy
	END

	SET @RQMTDescriptionID = @ExistingRQMTDescriptionID
	
	UPDATE RQMTSystem SET UpdatedBy = @UpdatedBy, UpdatedDate = @now WHERE RQMTSystemID = @RQMTSystemID
END


GO


