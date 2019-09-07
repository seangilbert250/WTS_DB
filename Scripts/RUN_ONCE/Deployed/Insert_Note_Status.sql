use [WTS]
go

declare
	@StatusTypeID int;
begin
	insert into StatusType(StatusType, [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values('Note', 'Note', (select max(SORT_ORDER) + 1 from StatusType), 'WTS', 'WTS');

	select @StatusTypeID = scope_identity();

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Open', 'Open', 1, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Closed', 'Closed', 2, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'N/A', 'N/A', 3, 'WTS', 'WTS');
end;