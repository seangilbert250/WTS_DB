use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORAttachment_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORAttachment_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORAttachment_Save]
	@AORID int,
	@AORAttachmentTypeID int,
	@AORReleaseAttachmentName nvarchar(150),
	@FileName nvarchar(150),
	@Description nvarchar(500),
	@FileData varbinary(max),
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @aorReleaseID int;
	declare @count int;

	select @aorReleaseID = AORReleaseID from AORRelease where AORID = @AORID and [Current] = 1;
	select @count = count(*) from AORReleaseAttachment where AORReleaseID = @aorReleaseID and AORAttachmentTypeID = @AORAttachmentTypeID and AORReleaseAttachmentName = @AORReleaseAttachmentName;

	if isnull(@count, 0) > 0
		begin
			set @Exists = 1;
			return;
		end;

	begin try
		insert into AORReleaseAttachment(AORReleaseID, AORAttachmentTypeID, AORReleaseAttachmentName, [FileName], [Description], FileData, CreatedBy, UpdatedBy)
		values (@aorReleaseID, @AORAttachmentTypeID, @AORReleaseAttachmentName, @FileName, @Description, @FileData, @UpdatedBy, @UpdatedBy);

		select @NewID = scope_identity();

		set @Saved = 1;
	end try
	begin catch
				
	end catch;
end;
