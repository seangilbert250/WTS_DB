use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[SRAttachment_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[SRAttachment_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[SRAttachment_Get]
	@SRAttachmentID int
as
begin
	select [FileName],
		FileData
	from SRAttachment
	where SRAttachmentID = @SRAttachmentID;
end;
