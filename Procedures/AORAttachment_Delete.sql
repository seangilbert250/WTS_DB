use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORAttachment_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORAttachment_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORAttachment_Delete]
	@AORReleaseAttachmentID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORReleaseAttachment where AORReleaseAttachmentID = @AORReleaseAttachmentID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from AORReleaseAttachment
		where AORReleaseAttachmentID = @AORReleaseAttachmentID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
