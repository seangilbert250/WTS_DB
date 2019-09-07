use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORCRLookupNarrative_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORCRLookupNarrative_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORCRLookupNarrative_Save]
	@CRID int,
	@Notes nvarchar(max),
	@BasisOfRisk nvarchar(max),
	@BasisOfUrgency nvarchar(max),
	@CustomerImpact nvarchar(max),
	@Issue nvarchar(max),
	@ProposedSolution nvarchar(max),
	@Rationale nvarchar(max),
	@WorkloadPriority nvarchar(max),
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;

	set @date = getdate();

	update AORCR
	set Notes = @Notes,
		BasisOfRisk = @BasisOfRisk,
		BasisOfUrgency = @BasisOfUrgency,
		CustomerImpact = @CustomerImpact,
		Issue = @Issue,
		ProposedSolution = @ProposedSolution,
		Rationale = @Rationale,
		WorkloadPriority = @WorkloadPriority,
		UpdatedBy = @UpdatedBy,
		UpdatedDate = @date
	where CRID = @CRID;

	set @Saved = 1;
end;
