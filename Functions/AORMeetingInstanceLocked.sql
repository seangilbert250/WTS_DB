use [WTS]
go

if object_id('[dbo].[AORMeetingInstanceLocked]', 'FN') is not null
drop function [dbo].[AORMeetingInstanceLocked];
go

create function [dbo].[AORMeetingInstanceLocked]
(
	@AORMeetingInstanceID int
)
returns bit
as
begin
	declare @count int = 0;
	declare @locked bit = 1;

	select @count = count(1)
	from AORMeetingInstance
	where AORMeetingInstanceID = @AORMeetingInstanceID;

	if (@count = 1)
		begin
			select @locked = Locked
			from AORMeetingInstance
			where AORMeetingInstanceID = @AORMeetingInstanceID;
		end;
	else
		begin
			set @locked = 0;
		end;

	return @locked;
end;
go
