use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[Image_Add]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[Image_Add]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[Image_Add]
	@ImageName nvarchar(500),
	@Description nvarchar(500),
	@FileName nvarchar(500),
	@FileData varbinary(max),
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	begin try
		insert into [Image]([ImageName], [Description], [FileName], [FileData], CreatedBy, UpdatedBy)
		values (@ImageName, @Description, @FileName, @FileData, @UpdatedBy, @UpdatedBy);

		select @NewID = scope_identity();

		set @Saved = 1;
	end try
	begin catch
				
	end catch;
end;
