use [WTS]
go

declare
	@StatusTypeID int;
begin
	insert into StatusType(StatusType, [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values('AORStatus', 'AOR Status', (select max(SORT_ORDER) + 1 from StatusType), 'WTS', 'WTS');

	select @StatusTypeID = scope_identity();

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Investigation', 'Investigation', 1, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Open - In Use', 'Open - In Use', 2, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Closed - Not in Use', 'Closed - Not in Use', 3, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Archived', 'Archived', 4, 'WTS', 'WTS');
end;