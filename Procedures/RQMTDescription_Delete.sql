use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[RQMTDescription_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[RQMTDescription_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[RQMTDescription_Delete]
	@RQMTDescriptionID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from RQMTDescription where RQMTDescriptionID = @RQMTDescriptionID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	select @HasDependencies = count(*) from RQMTDescriptionRQMTSystem where RQMTDescriptionID = @RQMTDescriptionID;

	--if isnull(@HasDependencies, 0) > 0
	--	begin
	--		return;
	--	end;

	begin try
		delete from RQMTDescription
		where RQMTDescriptionID = @RQMTDescriptionID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
