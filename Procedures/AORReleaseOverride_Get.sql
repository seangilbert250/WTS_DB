use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORReleaseOverride_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORReleaseOverride_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORReleaseOverride_Get]
	@AORReleaseID int,
	@IncludeArchive int
as
begin

	select aro.AORRelease_OverrideID
		 , aro.PriorityID
		 , pt.PRIORITYTYPE
		 , aro.Justification
		 , aro.Bln_Archive
		 , aro.Bln_SignOff
		 , aro.SignOff_Notes
		 , aro.SignOffBy
		 , aro.SignOffDate
		 , aro.CreatedBy
		 , aro.CreatedDate
		 , aro.UpdatedBy
		 , aro.UpdatedDate
		 , (select count(*) from AORRelease_OverrideHist where AORReleaseID = @AORReleaseID) as Count_OverrideHistory
	from AORRelease_Override aro
	left outer join PRIORITY p
	on aro.PriorityID = p.PRIORITYID
	left outer join PRIORITYTYPE pt
	on p.PRIORITYTYPEID = pt.PRIORITYTYPEID
	where aro.AORReleaseID = @AORReleaseID
	and pt.PRIORITYTYPE = 'AOR Estimation'
	and aro.Bln_Archive = @IncludeArchive
	;

end;

