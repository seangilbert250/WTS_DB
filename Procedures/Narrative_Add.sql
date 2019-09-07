USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_Add]    Script Date: 6/26/2018 3:26:44 PM ******/
DROP PROCEDURE [dbo].[Narrative_Add]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_Add]    Script Date: 6/26/2018 3:26:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Narrative_Add]
	@ProductVersionID int = 0,
	@ContractID int = 0,
	@MissionNarrativeID int = 0,
	@MissionNarrative nvarchar(max) = null,
	@MissionImageID int = null,
	@ProgramMGMTNarrativeID int = 0,
	@ProgramMGMTNarrative nvarchar(max) = null,
	@ProgramMGMTImageID int = null,
	@DeploymentNarrativeID int = 0,
	@DeploymentNarrative nvarchar(max) = null,
	@DeploymentImageID int = null,
	@ProductionNarrativeID int = 0,
	@ProductionNarrative nvarchar(max) = null,
	@ProductionImageID int = null,
	@CreatedBy nvarchar(255) = 'WTS',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @MissionID int = 0;
	DECLARE @ProgramMGMTID int = 0;
	DECLARE @DeploymentID int = 0;
	DECLARE @ProductionID int = 0;
	DECLARE @WorkloadAllocationID int = 0;
	SET @exists = 0;
	SET @newID = 0;

	-- MISSION
	IF (@MissionNarrative IS NOT NULL)
		BEGIN
			IF (ISNULL(@MissionNarrativeID,0) = 0)
				BEGIN
					SELECT @MissionID = ISNULL((SELECT n.NarrativeID
					FROM Narrative n
					LEFT JOIN Narrative_CONTRACT nac
					ON n.NarrativeID = nac.NarrativeID
					WHERE n.Narrative = 'Mission'
					AND nac.CONTRACTID = @ContractID
					AND nac.ProductVersionID = @ProductVersionID), 0)
				END;
			ELSE 
				BEGIN
					SET @MissionID = @MissionNarrativeID
				END;

			IF (ISNULL(@MissionID,0) = 0)
				BEGIN
					INSERT INTO Narrative(Narrative, [Description], Sort, Archive, CreatedBy, CreatedDate, UpdatedBy , UpdatedDate)
					VALUES('Mission', @MissionNarrative, 1, 0, @CreatedBy, @date, @CreatedBy, @date);

					SELECT @newID = SCOPE_IDENTITY();

					SELECT @exists = COUNT(*) 
					FROM Narrative_CONTRACT nc
					LEFT JOIN Narrative n
					ON nc.NarrativeID = n.NarrativeID
					WHERE n.NarrativeID = @newID
					AND nc.CONTRACTID = @CONTRACTID
					AND nc.ProductVersionID = @ProductVersionID
					;

					IF (ISNULL(@exists,0) > 0)
						BEGIN
							RETURN;
						END;

					INSERT INTO Narrative_CONTRACT(NarrativeID, CONTRACTID, ProductVersionID, ImageID, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					VALUES(@newID, @ContractID, @ProductVersionID, @MissionImageID, 0, @CreatedBy, @date, @CreatedBy, @date);
				END;
			ELSE
				BEGIN
					EXEC Narrative_Update @MissionID, @ProductVersionID, @ContractID, @MissionNarrative, @MissionImageID, 0, @CreatedBy, 0, 1
				END;
		END;

	-- PROGRAM MGMT
	IF (@ProgramMGMTNarrative IS NOT NULL)
		BEGIN
			SELECT @WorkloadAllocationID = wa.WorkloadAllocationID
			FROM WorkloadAllocation wa
			where wa.WorkloadAllocation = 'Program MGMT';

			IF (ISNULL(@ProgramMGMTNarrativeID,0) = 0)
				BEGIN
					SELECT @ProgramMGMTID = ISNULL((SELECT n.NarrativeID
					FROM Narrative n
					LEFT JOIN Narrative_CONTRACT nac
					ON n.NarrativeID = nac.NarrativeID
					WHERE n.Narrative = 'Program MGMT'
					AND nac.CONTRACTID = @ContractID
					AND nac.ProductVersionID = @ProductVersionID), 0)
				END;
			ELSE 
				BEGIN
					SET @ProgramMGMTID = @ProgramMGMTNarrativeID
				END;

			IF (ISNULL(@ProgramMGMTID,0) = 0)
				BEGIN
					INSERT INTO Narrative(Narrative, [Description], Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					VALUES('Program MGMT', @ProgramMGMTNarrative, 2, 0, @CreatedBy, @date, @CreatedBy, @date);

					SELECT @newID = SCOPE_IDENTITY();

					SELECT @exists = COUNT(*) 
					FROM Narrative_CONTRACT nc
					LEFT JOIN Narrative n
					ON nc.NarrativeID = n.NarrativeID
					WHERE n.NarrativeID = @newID
					AND nc.CONTRACTID = @CONTRACTID
					AND nc.ProductVersionID = @ProductVersionID
					;

					IF (ISNULL(@exists,0) > 0)
						BEGIN
							RETURN;
						END;

					INSERT INTO Narrative_CONTRACT(NarrativeID, CONTRACTID, ProductVersionID, WorkloadAllocationID, ImageID, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					VALUES(@newID, @ContractID, @ProductVersionID, @WorkloadAllocationID, @ProgramMGMTImageID, 0, @CreatedBy, @date, @CreatedBy, @date);
				END;
			ELSE
				BEGIN
					EXEC Narrative_Update @ProgramMGMTID, @ProductVersionID, @ContractID, @ProgramMGMTNarrative, @ProgramMGMTImageID, 0, @CreatedBy, 0, 1
				END;
		END;

	-- DEPLOYMENT
	IF (@DeploymentNarrative IS NOT NULL)
		BEGIN
			SELECT @WorkloadAllocationID = wa.WorkloadAllocationID
			FROM WorkloadAllocation wa
			where wa.WorkloadAllocation = 'Deployment';

			IF (ISNULL(@DeploymentNarrativeID,0) = 0)
				BEGIN
					SELECT @DeploymentID = ISNULL((SELECT n.NarrativeID
					FROM Narrative n
					LEFT JOIN Narrative_CONTRACT nac
					ON n.NarrativeID = nac.NarrativeID
					WHERE n.Narrative = 'Deployment'
					AND nac.CONTRACTID = @ContractID
					AND nac.ProductVersionID = @ProductVersionID), 0)
				END;
			ELSE 
				BEGIN
					SET @DeploymentID = @DeploymentNarrativeID
				END;

			IF (ISNULL(@DeploymentID,0) = 0)
				BEGIN
					INSERT INTO Narrative(Narrative, [Description], Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					VALUES('Deployment', @DeploymentNarrative, 3, 0, @CreatedBy, @date, @CreatedBy, @date);

					SELECT @newID = SCOPE_IDENTITY();

					SELECT @exists = COUNT(*) 
					FROM Narrative_CONTRACT nc
					LEFT JOIN Narrative n
					ON nc.NarrativeID = n.NarrativeID
					WHERE n.NarrativeID = @newID
					AND nc.CONTRACTID = @CONTRACTID
					AND nc.ProductVersionID = @ProductVersionID
					;

					IF (ISNULL(@exists,0) > 0)
						BEGIN
							RETURN;
						END;

					INSERT INTO Narrative_CONTRACT(NarrativeID, CONTRACTID, ProductVersionID, WorkloadAllocationID, ImageID, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					VALUES(@newID, @ContractID, @ProductVersionID, @WorkloadAllocationID, @DeploymentImageID, 0, @CreatedBy, @date, @CreatedBy, @date);
				END;
			ELSE
				BEGIN
					EXEC Narrative_Update @DeploymentID, @ProductVersionID, @ContractID, @DeploymentNarrative, @DeploymentImageID, 0, @CreatedBy, 0, 1
				END;
		END;

	-- PRODUCTION
	IF (@ProductionNarrative IS NOT NULL)
		BEGIN
			SELECT @WorkloadAllocationID = wa.WorkloadAllocationID
			FROM WorkloadAllocation wa
			where wa.WorkloadAllocation = 'Production';

			IF (ISNULL(@ProductionNarrativeID,0) = 0)
				BEGIN
					SELECT @ProductionID = ISNULL((SELECT n.NarrativeID
					FROM Narrative n
					LEFT JOIN Narrative_CONTRACT nac
					ON n.NarrativeID = nac.NarrativeID
					WHERE n.Narrative = 'Production'
					AND nac.CONTRACTID = @ContractID
					AND nac.ProductVersionID = @ProductVersionID), 0)
				END;
			ELSE 
				BEGIN
					SET @ProductionID = @ProductionNarrativeID
				END;

			IF (ISNULL(@ProductionID,0) = 0)
				BEGIN
					INSERT INTO Narrative(Narrative, [Description], Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					VALUES('Production', @ProductionNarrative, 4, 0, @CreatedBy, @date, @CreatedBy, @date);

					SELECT @newID = SCOPE_IDENTITY();

					SELECT @exists = COUNT(*) 
					FROM Narrative_CONTRACT nc
					LEFT JOIN Narrative n
					ON nc.NarrativeID = n.NarrativeID
					WHERE n.NarrativeID = @newID
					AND nc.CONTRACTID = @CONTRACTID
					AND nc.ProductVersionID = @ProductVersionID
					;

					IF (ISNULL(@exists,0) > 0)
						BEGIN
							RETURN;
						END;

					INSERT INTO Narrative_CONTRACT(NarrativeID, CONTRACTID, ProductVersionID, WorkloadAllocationID, ImageID, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					VALUES(@newID, @ContractID, @ProductVersionID, @WorkloadAllocationID, @ProductionImageID, 0, @CreatedBy, @date, @CreatedBy, @date);
				END;
			ELSE
				BEGIN
					EXEC Narrative_Update @ProductionID, @ProductVersionID, @ContractID, @ProductionNarrative, @ProductionImageID, 0, @CreatedBy, 0, 1
					SET @newID = 1;
				END;
		END;
END;


SELECT 'Executing File [Procedures\AORResourceList_Get.sql]';
GO

