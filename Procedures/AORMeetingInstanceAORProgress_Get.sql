use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingInstanceAORProgress_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeetingInstanceAORProgress_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORMeetingInstanceAORProgress_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int = 0
as
begin
	select AOR.AORID as AOR_ID,
		arl.AORName as AOR,
		arl.AORReleaseID as AORRelease_ID,
		'No' as ThresholdMet,
		0 as ExitCriteriaMet,
		0 as ExitCriteriaOpen,
		0 as ExitCriteriaNA,
		0 as EntranceCriteriaMet,
		0 as EntranceCriteriaOpen,
		0 as EntranceCriteriaNA
	from AORMeetingAOR ama
	join AORRelease arl
	on ama.AORReleaseID = arl.AORReleaseID
	join AOR
	on arl.AORID = AOR.AORID
	where ama.AORMeetingID = @AORMeetingID
	and ama.AORMeetingInstanceID_Add = @AORMeetingInstanceID
	and ama.AORMeetingInstanceID_Remove is null
	and AOR.Archive = 0;
end;
