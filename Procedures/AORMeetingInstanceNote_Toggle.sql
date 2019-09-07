use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingInstanceNote_Toggle]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeetingInstanceNote_Toggle]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORMeetingInstanceNote_Toggle]
	@AORMeetingID int,
	@AORMeetingInstanceID int,
	@AORMeetingNotesID int,
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
			update AORMeetingNotes
			set AORMeetingInstanceID_Remove = @AORMeetingInstanceID,
				RemoveDate = @date,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORMeetingNotesID = @AORMeetingNotesID;
		end;
	else if @Opt = 1
		begin
			update AORMeetingNotes
			set AddDate = @date,
				AORMeetingInstanceID_Remove = null,
				RemoveDate = null,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORMeetingNotesID = @AORMeetingNotesID;
		end;

	set @Saved = 1;
end;
