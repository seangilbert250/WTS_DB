use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[ReleaseAssessment_Deployment_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[ReleaseAssessment_Deployment_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[ReleaseAssessment_Deployment_Delete]
	@ReleaseAssessmentDeploymentID int,
	@Exists int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from ReleaseAssessment_Deployment where ReleaseAssessment_DeploymentID = @ReleaseAssessmentDeploymentID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	delete from ReleaseAssessment_Deployment
	where ReleaseAssessment_DeploymentID = @ReleaseAssessmentDeploymentID;

	set @Deleted = 1;
end;
