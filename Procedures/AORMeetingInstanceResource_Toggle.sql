use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingInstanceResource_Toggle]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeetingInstanceResource_Toggle]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORMeetingInstanceResource_Toggle]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@WTS_RESOURCEID int,
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
			delete from AORMeetingResourceAttendance
			where AORMeetingInstanceID = @AORMeetingInstanceID
			and WTS_RESOURCEID = @WTS_RESOURCEID;

			update AORMeetingResource
			set AORMeetingInstanceID_Remove = @AORMeetingInstanceID,
				RemoveDate = @date,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORMeetingID = @AORMeetingID
			and WTS_RESOURCEID = @WTS_RESOURCEID
			and AORMeetingInstanceID_Add = @AORMeetingInstanceID;
		end;
	else if @Opt = 1
		begin
			update AORMeetingResource
			set AddDate = @date,
				AORMeetingInstanceID_Remove = null,
				RemoveDate = null,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORMeetingID = @AORMeetingID
			and WTS_RESOURCEID = @WTS_RESOURCEID
			and AORMeetingInstanceID_Add = @AORMeetingInstanceID;
		end;

	set @Saved = 1;
end;
