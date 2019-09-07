use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[SRAttachmentList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[SRAttachmentList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[SRAttachmentList_Get]
	@SRID int = 0
as
begin
	select sra.SRID as SR_ID,
		sra.SRAttachmentID as SRAttachment_ID,
		sra.[FileName] as [File],
		sra.FileData,
		null as 'Z'
	from SRAttachment sra
	where (@SRID = 0 or sra.SRID = @SRID)
	order by sra.SRID;
end;
