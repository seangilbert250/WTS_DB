use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORCRLookup_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORCRLookup_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORCRLookup_Delete]
	@CRID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORCR where CRID = @CRID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from AORReleaseCR
		where CRID = @CRID;

		delete from AORSR
		where CRID = @CRID;

		delete from AORCR
		where CRID = @CRID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
