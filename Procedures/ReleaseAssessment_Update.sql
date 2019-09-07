USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ReleaseAssessment_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE ReleaseAssessment_Update
GO

CREATE PROCEDURE [dbo].[ReleaseAssessment_Update]
	@ReleaseAssessmentID int,
	@ReleaseID int,
	@ContractID int,
	@ReviewNarrative nvarchar(max) = null,
	@Mitigation bit,
	@MitigationNarrative nvarchar(max) = null,
	@Reviewed bit,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();

	UPDATE [dbo].[ReleaseAssessment]
	SET
		ProductVersionID = @ReleaseID
        ,CONTRACTID = @ContractID
        ,ReviewNarrative = @ReviewNarrative
        ,Mitigation = @Mitigation
		,MitigationNarrative = case when @Mitigation = 0 then 'N/A' else @MitigationNarrative end
        ,Reviewed = @Reviewed
        ,ReviewedBy = @UpdatedBy
        ,ReviewedDate = @date
        ,CREATEDBY = @UpdatedBy
        ,CREATEDDATE = @date
        ,UPDATEDBY = @UpdatedBy
        ,UPDATEDDATE = @date
	WHERE ReleaseAssessmentID = @ReleaseAssessmentID

	SET @saved = 1;
END;

