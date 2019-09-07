use [WTS]
go

insert into StatusType (StatusType, [DESCRIPTION], SORT_ORDER)
select 'SR', 'SR', max(SORT_ORDER) + 1 from StatusType;

insert into [STATUS] (StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
values ((select StatusTypeID from StatusType where StatusType = 'SR'), 'Submitted', 'Submitted', 1);

insert into [STATUS] (StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
values ((select StatusTypeID from StatusType where StatusType = 'SR'), 'Collaboration/In-Work', 'Collaboration/In-Work', 2);

insert into [STATUS] (StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
values ((select StatusTypeID from StatusType where StatusType = 'SR'), 'Reviewed', 'Reviewed', 3);

insert into [STATUS] (StatusTypeID, [STATUS], [DESCRIPTION], SORT_ORDER)
values ((select StatusTypeID from StatusType where StatusType = 'SR'), 'Resolved', 'Resolved', 4);
