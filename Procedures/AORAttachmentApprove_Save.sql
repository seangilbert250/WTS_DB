use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORAttachmentApprove_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORAttachmentApprove_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORAttachmentApprove_Save]
	@AORReleaseAttachmentID int,
	@Approve bit,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@Approved bit output,
	@ApprovedBy nvarchar(50) output,
	@ApprovedDate datetime output
as
begin
	set nocount on;

	declare @count int;
	declare @updatedByID int;
	declare @date datetime;

	set @date = getdate();

	select @count = count(*) from AORReleaseAttachment where AORReleaseAttachmentID = @AORReleaseAttachmentID;

	if isnull(@count, 0) > 0
		begin
			set @Exists = 1;
		end;

	select @updatedByID = WTS_RESOURCEID
	from WTS_RESOURCE
	where upper(USERNAME) = upper(@UpdatedBy);

	update AORReleaseAttachment
	set Approved = @Approve,
		ApprovedByID = case when @Approve = 1 then @updatedByID else null end,
		ApprovedDate = case when @Approve = 1 then @date else null end,
		UpdatedBy = @UpdatedBy,
		UpdatedDate = @date
	where AORReleaseAttachmentID = @AORReleaseAttachmentID;

	select @Approved = ara.Approved,
		@ApprovedBy = wre.USERNAME,
		@ApprovedDate = ara.ApprovedDate
	from AORReleaseAttachment ara
	left join WTS_RESOURCE wre
	on ara.ApprovedByID = wre.WTS_RESOURCEID
	where ara.AORReleaseAttachmentID = @AORReleaseAttachmentID;

	set @Saved = 1;
end;
