USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[ReleaseAssessment_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE ReleaseAssessment_Add
GO

CREATE PROCEDURE [dbo].[ReleaseAssessment_Add]
	@ReleaseID int,
	@ContractID int,
	@ReviewNarrative nvarchar(max) = null,
	@Mitigation bit,
	@MitigationNarrative nvarchar(max) = null,
	@Reviewed bit,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
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

	INSERT INTO ReleaseAssessment(
		ProductVersionID
		, CONTRACTID
		, ReviewNarrative
		, Mitigation
		, MitigationNarrative
		, Reviewed
		, ReviewedBy
		, ReviewedDate
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@ReleaseID
		, @ContractID
		, @ReviewNarrative
		, @Mitigation
		, case when @Mitigation = 0 then 'N/A' else @MitigationNarrative end
		, @Reviewed
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	SELECT @newID = SCOPE_IDENTITY();
END;

