use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[SRAttachment_Add]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[SRAttachment_Add]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[SRAttachment_Add]
	@SRID int,
	@FileName nvarchar(150),
	@FileData varbinary(max),
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	begin try
		insert into SRAttachment(SRID, [FileName], [FileData], CreatedBy, UpdatedBy)
		values (@SRID, @FileName, @FileData, @UpdatedBy, @UpdatedBy);

		select @NewID = scope_identity();

		set @Saved = 1;
	end try
	begin catch
				
	end catch;
end;
