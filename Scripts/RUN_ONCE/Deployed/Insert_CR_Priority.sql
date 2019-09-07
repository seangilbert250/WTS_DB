use [WTS]
go

declare
	@PriorityTypeID int;
begin
	insert into PRIORITYTYPE(PRIORITYTYPE, [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values('AORCR', 'AORCR', (select max(SORT_ORDER) + 1 from PRIORITYTYPE), 'WTS', 'WTS');

	select @PriorityTypeID = scope_identity();

	insert into [PRIORITY](PRIORITYTYPEID, [PRIORITY], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@PriorityTypeID, 'High', 'High', 1, 'WTS', 'WTS');

	insert into [PRIORITY](PRIORITYTYPEID, [PRIORITY], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@PriorityTypeID, 'Medium', 'Medium', 2, 'WTS', 'WTS');

	insert into [PRIORITY](PRIORITYTYPEID, [PRIORITY], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@PriorityTypeID, 'Low', 'Low', 3, 'WTS', 'WTS');

	insert into [PRIORITY](PRIORITYTYPEID, [PRIORITY], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@PriorityTypeID, 'Auxiliary', 'Auxiliary', 4, 'WTS', 'WTS');
end;