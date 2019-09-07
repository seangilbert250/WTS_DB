use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[WorkItem_History_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[WorkItem_History_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[WorkItem_History_Delete]
	@WorkItem_HistoryID int,
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from WorkItem_History where WorkItem_HistoryID = @WorkItem_HistoryID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from WorkItem_History
		where WorkItem_HistoryID = @WorkItem_HistoryID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
