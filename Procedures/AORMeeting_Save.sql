use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeeting_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeeting_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORMeeting_Save]
	@NewAORMeeting bit,
	@AORMeetingID int,
	@AORMeetingName nvarchar(150),
	@Description nvarchar(500),
	@Notes nvarchar(max),
	@AORFrequencyID int,
	@AutoCreateMeetings bit,
	@PrivateMeeting bit,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @date datetime;
	declare @count int;

	set @date = getdate();

	if @NewAORMeeting = 1
		begin
			select @count = count(*) from AORMeeting where AORMeetingName = @AORMeetingName;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;

			begin try
				insert into AORMeeting(AORMeetingName, [Description], Notes, AORFrequencyID, AutoCreateMeetings, [Private], CreatedBy, UpdatedBy)
				values(@AORMeetingName, @Description, @Notes, @AORFrequencyID, @AutoCreateMeetings, @PrivateMeeting, @UpdatedBy, @UpdatedBy);
	
				select @NewID = scope_identity();

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @AORMeetingID > 0
		begin
			select @count = count(*) from AORMeeting where AORMeetingName = @AORMeetingName and AORMeetingID != @AORMeetingID;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;

			update AORMeeting
			set AORMeetingName = @AORMeetingName,
				[Description] = @Description,
				Notes = @Notes,
				AORFrequencyID = @AORFrequencyID,
				AutoCreateMeetings = @AutoCreateMeetings,
				[Private] = @PrivateMeeting,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where AORMeetingID = @AORMeetingID;

			set @Saved = 1;
		end;
end;
