use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORCRLookupList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORCRLookupList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORCRLookupList_Get]
	@CRID int = 0
as
begin
	select acr.CRName,
		acr.Title,
		acr.Notes,
		acr.Websystem,
		acr.CSDRequiredNow,
		acr.RelatedRelease,
		acr.Subgroup,
		acr.DesignReview,
		acr.ITIPOC,
		acr.CustomerPriorityList,
		acr.GovernmentCSRD,
		acr.PrimarySR,
		c.CONTRACTID,
		c.[CONTRACT],
		acr.CAMPriority,
		acr.LCMBPriority,
		acr.AirstaffPriority,
		acr.RiskOfPTS,
		acr.CustomerPriority,
		acr.ITIPriority,
		s.StatusID,
		s.[STATUS],
		acr.LCMBSubmittedDate,
		acr.LCMBApprovedDate,
		acr.ERBISMTSubmittedDate,
		acr.ERBISMTApprovedDate,
		acr.BasisOfRisk,
		acr.BasisOfUrgency,
		acr.CustomerImpact,
		acr.Issue,
		acr.ProposedSolution,
		acr.Rationale,
		acr.WorkloadPriority,
		acr.Imported,
		lower(acr.CreatedBy) as CreatedBy_ID,
		acr.CreatedDate as CreatedDate_ID,
		lower(acr.UpdatedBy) as UpdatedBy_ID,
		acr.UpdatedDate as UpdatedDate_ID
	from AORCR acr
	left join [STATUS] s
	on acr.StatusID = s.STATUSID
	left join [CONTRACT] c
	on acr.ContractID = c.CONTRACTID
	where (@CRID = 0 or acr.CRID = @CRID)
	order by acr.Sort, upper(acr.CRName);
end;
