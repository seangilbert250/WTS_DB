use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingInstanceAOR_Toggle]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeetingInstanceAOR_Toggle]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORMeetingInstanceAOR_Toggle]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@AORReleaseID int,
	@Opt int,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;

	set @date = getdate();

	if @Opt = 0
		begin
			update AORMeetingAOR
			set AORMeetingInstanceID_Remove = @AORMeetingInstanceID,
				RemoveDate = @date,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORMeetingID = @AORMeetingID
			and AORReleaseID = @AORReleaseID
			and AORMeetingInstanceID_Add = @AORMeetingInstanceID;
		end;
	else if @Opt = 1
		begin
			update AORMeetingAOR
			set AddDate = @date,
				AORMeetingInstanceID_Remove = null,
				RemoveDate = null,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORMeetingID = @AORMeetingID
			and AORReleaseID = @AORReleaseID
			and AORMeetingInstanceID_Add = @AORMeetingInstanceID;

			insert into AORMeetingResource(AORMeetingID, WTS_RESOURCEID, AORMeetingInstanceID_Add, AddDate, CreatedBy, UpdatedBy)
			select distinct @AORMeetingID,
				arr.WTS_RESOURCEID,
				@AORMeetingInstanceID,
				@date,
				@UpdatedBy,
				@UpdatedBy
			from AORReleaseResource arr
			where arr.AORReleaseID = @AORReleaseID
			and not exists (
				select 1
				from AORMeetingResource amr
				where amr.AORMeetingID = @AORMeetingID
				and arr.WTS_RESOURCEID = amr.WTS_RESOURCEID
				and (amr.AORMeetingInstanceID_Add = @AORMeetingInstanceID or amr.AORMeetingInstanceID_Remove = @AORMeetingInstanceID)
			);
		end;

	set @Saved = 1;
end;
