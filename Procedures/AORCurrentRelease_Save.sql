use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORCurrentRelease_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORCurrentRelease_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORCurrentRelease_Save]
	@ProductVersionID int,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;

	set @date = getdate();

	begin try
		update AORCurrentRelease
		set [Current] = 0,
			UpdatedBy = @UpdatedBy,
			UpdatedDate = @date
		where [Current] = 1;

		insert into AORCurrentRelease(ProductVersionID, [Current], CreatedBy, UpdatedBy)
		values (@ProductVersionID, 1, @UpdatedBy, @UpdatedBy);

		set @Saved = 1;
	end try
	begin catch
		
	end catch;
end;
