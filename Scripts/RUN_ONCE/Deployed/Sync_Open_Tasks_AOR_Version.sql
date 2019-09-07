use wts
go

begin
	declare @taskID int;

	declare curTasks cursor for
	select WORKITEMID
	from WORKITEM;

	open curTasks;

	fetch next from curTasks
	into @taskID;

	while @@fetch_status = 0
		begin
			exec AORTaskProductVersion_Save
				@TaskID = @taskID,
				@Add = 0,
				@UpdatedBy = 'WTS',
				@Saved = null;

			fetch next from curTasks
			into @taskID;
		end;
	close curTasks;
	deallocate curTasks;
end;