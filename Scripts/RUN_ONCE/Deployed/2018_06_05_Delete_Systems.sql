use [WTS]
go

/*
16	Delete 08 (Update Tasks System to R&D CAFDEx set work area to R&D ETS)
20	Delete 09 (Update Tasks System to R&D CAFDEx set work area to R&D PIC-Sys)
30	Delete 02 (Update Tasks System to R&D CAFDEx set work area to OFCO)
38	Delete 05 (Update Tasks System to R&D CAFDEx set work area to R&D Template)
42	Delete sysname 06 (change tasks to Contracting)
49	Delete 05 (Update Tasks System to R&D CAFDEx set work area to R&D LMS)
50	Delete 03 (Update Tasks System to R&D CAFDEx set work area to Non Fly DLR)
53	Delete 01 (Update Tasks System to R&D CAFDEx)
54	Delete 04 (Update Tasks System to R&D CAFDEx set work area to R&D FHP)
*/

insert into WorkArea (WorkArea, ProposedPriorityRank)
values ('R&D ETS', 0);
insert into WorkArea (WorkArea, ProposedPriorityRank)
values ('R&D PIC-Sys', 0);
insert into WorkArea (WorkArea, ProposedPriorityRank)
values ('R&D Template', 0);
insert into WorkArea (WorkArea, ProposedPriorityRank)
values ('R&D LMS', 0);

update WORKITEM
set WTS_SYSTEMID = 9, --R&D CAFDEx
WorkAreaID = (select WorkAreaID from WorkArea where WorkArea = 'R&D ETS')
where WTS_SYSTEMID = 16;

update WORKITEM
set WTS_SYSTEMID = 9, --R&D CAFDEx
WorkAreaID = (select WorkAreaID from WorkArea where WorkArea = 'R&D PIC-Sys')
where WTS_SYSTEMID = 20;

update WORKITEM
set WTS_SYSTEMID = 9, --R&D CAFDEx
WorkAreaID = (select WorkAreaID from WorkArea where WorkArea = 'R&D Template')
where WTS_SYSTEMID = 38;

update WORKITEM
set WTS_SYSTEMID = 9, --R&D CAFDEx
WorkAreaID = (select WorkAreaID from WorkArea where WorkArea = 'R&D LMS')
where WTS_SYSTEMID = 49;

delete from WTS_SYSTEM_WORKACTIVITY
where WTS_SYSTEMID in (16,20,30,38,42,49,50,53,54);

delete from AORReleaseSystem
where WTS_SYSTEMID in (16,20,30,38,42,49,50,53,54);

delete from WTS_SYSTEM_RESOURCE
where WTS_SYSTEMID in (16,20,30,38,42,49,50,53,54);

delete from Allocation_System
where WTS_SYSTEMID in (16,20,30,38,42,49,50,53,54);

delete from WorkArea_System
where WTS_SYSTEMID in (16,20,30,38,42,49,50,53,54);

delete from WTS_SYSTEM
where WTS_SYSTEMID in (16,20,30,38,42,49,50,53,54);
