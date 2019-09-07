USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_Delete]    Script Date: 10/9/2018 2:38:54 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstance_Delete]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_Delete]    Script Date: 10/9/2018 2:38:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AORMeetingInstance_Delete]
	@AORMeetingInstanceID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORMeetingInstance where AORMeetingInstanceID = @AORMeetingInstanceID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from AORMeetingAOR
		where AORMeetingInstanceID_Add = @AORMeetingInstanceID
		or AORMeetingInstanceID_Remove = @AORMeetingInstanceID;

		delete from AORMeetingResourceAttendance
		where AORMeetingInstanceID = @AORMeetingInstanceID;

		delete from AORMeetingResource
		where AORMeetingInstanceID_Add = @AORMeetingInstanceID
		or AORMeetingInstanceID_Remove = @AORMeetingInstanceID;

		delete from AORMeetingNotes
		where AORMeetingInstanceID_Add = @AORMeetingInstanceID
		or AORMeetingInstanceID_Remove = @AORMeetingInstanceID;

		select AttachmentID
		into #attachmentids
		from AORMeetingInstanceAttachment amia
		join AORMeetingInstance ami on ami.AORMeetingInstanceID = amia.AORMeetingInstanceID
		where ami.AORMeetingInstanceID = @AORMeetingInstanceID
				
		delete from AORMeetingInstanceAttachment
		where AORMeetingInstanceID = @AORMeetingInstanceID

		delete from Attachment
		where AttachmentID 
		in (select AttachmentID from #attachmentids)

		delete from AORMeetingInstance
		where AORMeetingInstanceID = @AORMeetingInstanceID;

		set @Deleted = 1;

		drop table #attachmentids
	end try
	begin catch
		
	end catch;
end;
GO


