use [WTS]
go

declare
	@StatusTypeID int;
begin
	insert into StatusType(StatusType, [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values('CMMI', 'CMMI', (select max(SORT_ORDER) + 1 from StatusType), 'WTS', 'WTS');

	select @StatusTypeID = scope_identity();

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'In Progress', 'In Progress', 1, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'In QA', 'In QA', 2, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Following', 'Following', 3, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Followed', 'Followed', 4, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Concerns', 'Concerns', 5, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Not Required', 'Not Required', 6, 'WTS', 'WTS');

	insert into [STATUS](StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER, CREATEDBY, UPDATEDBY)
	values (@StatusTypeID, 'Complete', 'Complete', 7, 'WTS', 'WTS');
end;