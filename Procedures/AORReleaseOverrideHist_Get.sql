use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORReleaseOverrideHist_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORReleaseOverrideHist_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORReleaseOverrideHist_Get]
	@AORReleaseID int,
	@IncludeArchive int
as
begin

	select isnull(p.PRIORITY,'') as  Old_Priority
		 , isnull(p2.PRIORITY,'') as New_Priority
		 , isnull(aroh.Old_Justification,'') as Old_Justification
		 , isnull(aroh.New_Justification,'') as New_Justification
		 , case when aroh.Old_Bln_SignOff = 1 then 'Yes' else 'No' end as Old_Bln_SignOff
		 , case when aroh.New_Bln_SignOff = 1 then 'Yes' else 'No' end as New_Bln_SignOff
		 , case when aroh.Bln_Archive = 1 then 'Yes' else 'No' end as Bln_Archive
		 , convert(varchar, aroh.CreatedDate, 101) + right(convert(varchar(32),aroh.CreatedDate,100),8) as CreatedDate
		 , aroh.CreatedBy
		 , convert(varchar, aroh.UpdatedDate, 101) + right(convert(varchar(32),aroh.UpdatedDate,100),8) as UpdatedDate
		 , aroh.UpdatedBy
	from AORRelease_OverrideHist aroh
	left outer join PRIORITY p
	on isnull(aroh.Old_PriorityID,-1) = p.PRIORITYID
	left outer join PRIORITY p2
	on isnull(aroh.New_PriorityID,-1) = p2.PRIORITYID
	where AORReleaseID = @AORReleaseID
	order by aroh.AORRelease_OverrideHistID asc
	;

end;