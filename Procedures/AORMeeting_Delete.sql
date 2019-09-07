USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeeting_Delete]    Script Date: 10/9/2018 2:38:28 PM ******/
DROP PROCEDURE [dbo].[AORMeeting_Delete]
GO

/****** Object:  StoredProcedure [dbo].[AORMeeting_Delete]    Script Date: 10/9/2018 2:38:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORMeeting_Delete]
	@AORMeetingID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORMeeting where AORMeetingID = @AORMeetingID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;	

	begin try
		delete from AORMeetingAOR
		where AORMeetingID = @AORMeetingID;

		delete from AORMeetingResourceAttendance
		where exists (
			select 1
			from AORMeetingInstance ami
			where ami.AORMeetingInstanceID = AORMeetingResourceAttendance.AORMeetingInstanceID
			and ami.AORMeetingID = @AORMeetingID
		);		

		delete from AORMeetingResource
		where AORMeetingID = @AORMeetingID;

		delete from AORMeetingNotes
		where AORMeetingID = @AORMeetingID;

		select AttachmentID
		into #attachmentids
		from AORMeetingInstanceAttachment amia
		join AORMeetingInstance ami on ami.AORMeetingInstanceID = amia.AORMeetingInstanceID
		join AORMeeting am on am.AORMeetingID = ami.AORMeetingID
		where am.AORMeetingID = @AORMeetingID				
		
		select AORMeetingInstanceID
		into #meetinginstances
		from AORMeetingInstance ami
		JOIN AORMeeting am on am.AORMeetingID = ami.AORMeetingID
		where am.AORMeetingID = @AORMeetingID
		
		delete from AORMeetingInstanceAttachment
		where AORMeetingInstanceID in (select AORMeetingInstanceID from #meetinginstances)

		delete from Attachment
		where AttachmentID in (select AttachmentID from #attachmentids)

		delete from AORMeetingInstance
		where AORMeetingID = @AORMeetingID;

		delete from AORMeetingEmail
		where AORMeetingID = @AORMeetingID

		delete from AORMeeting
		where AORMeetingID = @AORMeetingID;

		set @Deleted = 1;

		drop table #attachmentids
		drop table #meetinginstances
	end try
	begin catch
		select dbo.GetErrorInfo()
	end catch;
end;
GO


