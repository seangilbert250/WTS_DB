use [WTS]
go

insert into PRIORITYTYPE(PRIORITYTYPE, [DESCRIPTION], SORT_ORDER)
values ('SR Rank', 'SR Rank', 8);

insert into PRIORITY(PRIORITYTYPEID, PRIORITY, [DESCRIPTION], SORT_ORDER)
values ('8', '1 – PTS Workload', '1 – PTS Workload', 1);

insert into PRIORITY(PRIORITYTYPEID, PRIORITY, [DESCRIPTION], SORT_ORDER)
values ('8', '2 – Release Workload', '2 – Release Workload', 2);

insert into PRIORITY(PRIORITYTYPEID, PRIORITY, [DESCRIPTION], SORT_ORDER)
values ('8', '3 – Recurring Workload', '3 – Recurring Workload', 3);

insert into PRIORITY(PRIORITYTYPEID, PRIORITY, [DESCRIPTION], SORT_ORDER)
values ('8', '4 – Staged/Future Release', '4 – Staged/Future Release', 4);

insert into PRIORITY(PRIORITYTYPEID, PRIORITY, [DESCRIPTION], SORT_ORDER)
values ('8', '5 – Unprioritized Workload', '5 – Unprioritized Workload', 5);

insert into PRIORITY(PRIORITYTYPEID, PRIORITY, [DESCRIPTION], SORT_ORDER)
values ('8', '6 – Closed Workload', '6 – Closed Workload', 6);

alter table SR
add SRRankID int not null default(0);
go