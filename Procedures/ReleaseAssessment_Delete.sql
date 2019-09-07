use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[ReleaseAssessment_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[ReleaseAssessment_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[ReleaseAssessment_Delete]
	@ReleaseAssessmentID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from ReleaseAssessment where ReleaseAssessmentID = @ReleaseAssessmentID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	delete from ReleaseAssessment_Deployment
	where ReleaseAssessmentID = @ReleaseAssessmentID;

	delete from ReleaseAssessment
	where ReleaseAssessmentID = @ReleaseAssessmentID;

	set @Deleted = 1;
end;
