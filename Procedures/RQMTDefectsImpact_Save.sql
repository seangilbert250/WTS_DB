USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpact_Save]    Script Date: 9/7/2018 1:48:21 PM ******/
DROP PROCEDURE [dbo].[RQMTDefectsImpact_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMTDefectsImpact_Save]    Script Date: 9/7/2018 1:48:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[RQMTDefectsImpact_Save]
	@RQMT_ID int,
	@SYSTEM_ID int,
	@RQMTSystemDefectID int,
	@Description nvarchar(max),
	@Verified int,
	@Resolved int,
	@ContinueToReview int,
	@ImpactID int,
	@RQMTStageID int,
	@Mitigation nvarchar(max),
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;
	declare @RQMTSystemID int;
	declare @dataExists INT = 0;
	declare @now datetime = getdate()

	select @RQMTSystemID = RQMTSystemID
	from RQMTSystem
	where RQMTID = @RQMT_ID
	and WTS_SYSTEMID = @SYSTEM_ID;

	select @dataExists = count(*)
	from RQMTSystemDefect
	where RQMTSystemDefectID = @RQMTSystemDefectID
	and RQMTSystemID = @RQMTSystemID;

	if (@ImpactID is null or @ImpactID <= 0)
	begin
		set @ImpactID = (select RQMTAttributeID from RQMTAttribute where RQMTAttributeTypeID = 2 and RQMTAttribute = 'None')
	end

	if (@RQMTStageID <= 0) SET @RQMTStageID = NULL
	
	if @dataExists > 0
	begin
		declare @Description_OLD NVARCHAR(MAX),
			@Verified_OLD int,
			@Resolved_OLD int,
			@ContinueToReview_OLD int,
			@ImpactID_OLD int,
			@RQMTStageID_OLD int,
			@Mitigation_OLD NVARCHAR(MAX)
				
		select @Description_OLD = Description, @Verified_OLD = Verified, @Resolved_OLD = Resolved, @ImpactID_OLD = ImpactID, @RQMTStageID_OLD = RQMTStageID, @Mitigation_OLD = Mitigation
		from RQMTSystemDefect WHERE RQMTSystemDefectID = @RQMTSystemDefectID

		UPDATE RQMTSystemDefect
		SET Description = @Description
			, Verified = @Verified
			, Resolved = @Resolved
			, ContinueToReview = @ContinueToReview
			, ImpactID = @ImpactID
			, RQMTStageID = @RQMTStageID
			, Mitigation = @Mitigation
			, UpdatedBy = @UpdatedBy
			, UpdatedDate = @now
		WHERE  RQMTSystemDefectID = @RQMTSystemDefectID;

		EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 5, 'RQMTDefect', @Description_OLD, @Description, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 5, 'RQMTDefectVerified', @Verified_OLD, @Verified, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 5, 'RQMTDefectResolved', @Resolved_OLD, @Resolved, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 5, 'RQMTDefectContinueToReview', @ContinueToReview_OLD, @ContinueToReview, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 5, 'RQMTDefectImpact', @ImpactID_OLD, @ImpactID, @now, @UpdatedBy
		--EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 5, 'RQMTDefectStage', @RQMTStageID_OLD, @RQMTStageID, @now, @UpdatedBy
		EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 5, 'RQMTDefectMitigation', @Mitigation_OLD, @Mitigation, @now, @UpdatedBy
	end
	else
	begin	
		INSERT INTO RQMTSystemDefect(RQMTSystemID, Description, Verified, Resolved, ContinueToReview, ImpactID, RQMTStageID, Mitigation, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
		values(@RQMTSystemID, @Description, @Verified, @Resolved, @ContinueToReview, @ImpactID, @RQMTStageID, @Mitigation, @UpdatedBy, @now, @UpdatedBy, @now);

		SET @RQMTSystemDefectID = SCOPE_IDENTITY()

		IF @RQMTSystemDefectID > 0
		BEGIN
			DECLARE @txt VARCHAR(100) = 'DEFECT ' + CONVERT(VARCHAR(100), @RQMTSystemDefectID) + ' ADDED'
			EXEC dbo.AuditLog_Save @RQMT_ID, NULL, 1, 1, 'RQMTDefect', NULL, @txt, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTSystemDefectID', NULL, 'DEFECT CREATED', @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTDefect', NULL, @Description, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTDefectVerified', NULL, @Verified, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTDefectResolved', NULL, @Resolved, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTDefectContinueToReview', NULL, @ContinueToReview, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTDefectImpact', NULL, @ImpactID, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTDefectStage', NULL, @RQMTStageID, @now, @UpdatedBy
			EXEC dbo.AuditLog_Save @RQMTSystemDefectID, @RQMTSystemID, 3, 1, 'RQMTDefectMitigation', NULL, @Mitigation, @now, @UpdatedBy
		END
	end

	set @Saved = 1;

end;

GO


