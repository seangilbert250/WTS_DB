use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORSRTask_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORSRTask_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORSRTask_Delete]
	@TaskID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from WORKITEM where WORKITEMID = @TaskID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		update WORKITEM
		set SR_Number = null
		where WORKITEMID = @TaskID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
