USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_Copy]    Script Date: 5/4/2018 9:01:40 AM ******/
DROP PROCEDURE [dbo].[Narrative_Copy]
GO

/****** Object:  StoredProcedure [dbo].[Narrative_Copy]    Script Date: 5/4/2018 9:01:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Narrative_Copy]
	@Narrative nvarchar(500),
	@OldProductVersionID int,
	@NewProductVersionID int,
	@CreatedBy nvarchar(255) = 'WTS',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;

	SELECT @exists = COUNT(*) 
	FROM Narrative n
	left join Narrative_CONTRACT nc
	on n.NarrativeID = nc.NarrativeID
	WHERE n.Narrative = @Narrative
	AND nc.ProductVersionID = @NewProductVersionID
	;

	IF (ISNULL(@exists,0) > 0)
		BEGIN
			set @exists = 1;
			RETURN;
		END;
	ELSE 
		BEGIN

			with
			w_narratives as (
				select distinct n.Narrative,
					n.Description
				FROM Narrative n
				LEFT JOIN Narrative_CONTRACT nc
				on n.NarrativeID = nc.NarrativeID
				where n.Narrative = @Narrative
				and nc.ProductVersionID = @OldProductVersionID
			)
			INSERT INTO Narrative(
				Narrative
				, [Description]
				, Archive
				, CreatedBy
				, CreatedDate
				, UpdatedBy
				, UpdatedDate
			)
			SELECT 
				wn.Narrative
				, wn.Description
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			from w_narratives wn;

			with
			w_narrative_contracts as (
				select distinct n.NarrativeID,
					n.Narrative,
					n.[Description],
					nc.CONTRACTID,
					nc.WorkloadAllocationID,
					nc.ImageID
				FROM Narrative n
				LEFT JOIN Narrative_CONTRACT nc
				on n.NarrativeID = nc.NarrativeID
				where n.Narrative = @Narrative
				and nc.ProductVersionID = @OldProductVersionID
			)
			INSERT INTO Narrative_CONTRACT(
				NarrativeID
				, CONTRACTID
				, ProductVersionID
				, WorkloadAllocationID
				, ImageID
				, Archive
				, CreatedBy
				, CreatedDate
				, UpdatedBy
				, UpdatedDate
			)
			SELECT DISTINCT
				n.NarrativeID
				, wnc.CONTRACTID
				, @NewProductVersionID
				, wnc.WorkloadAllocationID
				, wnc.ImageID
				, 0
				, @CreatedBy
				, @date
				, @CreatedBy
				, @date
			FROM  Narrative n
			left join Narrative_CONTRACT nc
			on n.NarrativeID = nc.NarrativeID
			join w_narrative_contracts wnc
			on n.Narrative = wnc.Narrative
			WHERE n.Narrative = @Narrative
			and n.[Description] = wnc.[Description]
			and n.NarrativeID NOT IN (select NarrativeID from w_narrative_contracts)
			and nc.NarrativeID is null
			and nc.ProductVersionID is null;

			SELECT @newID = SCOPE_IDENTITY();
		END;
END;

GO

