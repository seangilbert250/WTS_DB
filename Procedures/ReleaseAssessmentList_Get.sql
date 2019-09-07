use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[ReleaseAssessmentList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[ReleaseAssessmentList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[ReleaseAssessmentList_Get]
as
begin
	select ra.ReleaseAssessmentID,
		pv.ProductVersionID,
		pv.ProductVersion,
		c.CONTRACTID,
		c.[CONTRACT],
		(select count(1) from ReleaseAssessment_Deployment rad where rad.ReleaseAssessmentID = ra.ReleaseAssessmentID) as DeploymentCount,
		ra.ReviewNarrative,
		case when ra.Mitigation = 1 then 'Yes' else 'No' end as Mitigation,
		ra.MitigationNarrative,
		case when ra.Reviewed = 1 then 'Yes' else 'No' end as Reviewed,
		ra.ReviewedBy,
		ra.ReviewedDate,
		ra.Sort,
		case when ra.Archive = 1 then 'Yes' else 'No' end as Archive,
		ra.CreatedBy,
		ra.CreatedDate,
		ra.UpdatedBy,
		ra.UpdatedDate
	from ReleaseAssessment ra
	left join ProductVersion pv
	on ra.ProductVersionID = pv.ProductVersionID
	left join [CONTRACT] c
	on ra.CONTRACTID = c.CONTRACTID
	order by pv.ProductVersionID, c.CONTRACTID, ra.Sort;
end;
