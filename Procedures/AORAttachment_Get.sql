use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORAttachment_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORAttachment_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORAttachment_Get]
	@AORReleaseAttachmentID int
as
begin
	select [FileName],
		FileData
	from AORReleaseAttachment
	where AORReleaseAttachmentID = @AORReleaseAttachmentID;
end;
