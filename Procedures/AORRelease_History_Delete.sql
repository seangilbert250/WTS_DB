use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORRelease_History_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORRelease_History_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORRelease_History_Delete]
	@AORRelease_HistoryID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORRelease_History where AORRelease_HistoryID = @AORRelease_HistoryID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from AORRelease_History
		where AORRelease_HistoryID = @AORRelease_HistoryID;

		set @Deleted = 1;
	end try
	begin catch

	end catch;
end;
