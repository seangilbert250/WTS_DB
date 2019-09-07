use [WTS]
go

declare
	@StatusTypeID int;
begin
	insert into StatusType(StatusType, [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values('Inv', 'Investigation', (select max(SORT_ORDER) + 1 from StatusType), 'WTS', 'WTS');

	select @StatusTypeID = scope_identity();

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Inv1', 'Ready for Investigation', 1, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Inv2', 'Initial Presentation', 2, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Inv3', 'Investigation In Progress', 3, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Inv4', 'Ready for Review', 4, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Inv5', 'Investigation Complete', 5, 'WTS', 'WTS');
end;