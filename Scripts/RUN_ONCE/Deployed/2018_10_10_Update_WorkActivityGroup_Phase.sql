use [WTS]
go

declare @date datetime = getdate();

update WORKITEMTYPE
set WorkActivityGroupID = 12
where WorkActivityGroupID in (3,4,5,6,7,9,10);

delete from WorkActivityGroup
where WorkActivityGroupID not in (1,2,8,11,12);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (12, 2, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (12, 3, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (12, 4, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (12, 5, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (12, 6, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (12, 7, 0, 0, 'WTS', @date, 'WTS', @date);

--cy
insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (2, 12, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (2, 7, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (2, 13, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (2, 14, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (2, 15, 0, 0, 'WTS', @date, 'WTS', @date);

--bd
insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (1, 16, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (1, 17, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (1, 18, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (1, 19, 0, 0, 'WTS', @date, 'WTS', @date);

--tr
insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (11, 2, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (11, 3, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (11, 4, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (11, 5, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (11, 6, 0, 0, 'WTS', @date, 'WTS', @date);

insert into WorkActivityGroup_Phase(WorkActivityGroupID, PDDTDR_PHASEID, Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
values (11, 7, 0, 0, 'WTS', @date, 'WTS', @date);

go
