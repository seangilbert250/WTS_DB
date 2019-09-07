use [WTS]
go

declare
	@StatusTypeID int;
begin
	insert into StatusType(StatusType, [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values('IP', 'IP', (select max(SORT_ORDER) + 1 from StatusType), 'WTS', 'WTS');

	select @StatusTypeID = scope_identity();

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Ready', 'Ready', 1, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'In Progress', 'In Progress', 2, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Complete', 'Complete', 3, 'WTS', 'WTS');
end;